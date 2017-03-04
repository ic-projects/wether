{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE FlexibleInstances   #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import           Control.Monad.IO.Class
import           Crypto.Hash.SHA256
import           Crypto.Secp256k1
import           Data.Aeson
import           Data.ByteString.Char8
import           Data.ByteString.Lazy.Char8
import           Data.Char
import           Data.List
import           Data.Maybe
import           Data.Time.Clock.POSIX
import           Data.Time.Format
import           Happstack.Lite
import           Network.HTTP.Simple

testForecastJSON :: IO()
testForecastJSON = do
  x <- Data.ByteString.Lazy.Char8.readFile "forecast.json"
  print (decode x :: Maybe ForecastResponse)

testPlannerJSON :: IO()
testPlannerJSON = do
  x <- Data.ByteString.Lazy.Char8.readFile "planner.json"
  print (decode x :: Maybe PlannerResponse)

newtype ForecastDay = ForecastDay {
    pop :: Int
  } deriving Show

newtype SimpleForecast = SimpleForecast {
    forecastday :: [ForecastDay]
  } deriving Show

newtype Forecast = Forecast {
    simpleforecast :: SimpleForecast
  } deriving Show

newtype ForecastResponse = ForecastResponse {
    forecast :: Forecast
  } deriving Show

instance FromJSON ForecastDay where
  parseJSON (Object o) =
    ForecastDay <$> o .: "pop"
  parseJSON _ = mzero

instance FromJSON SimpleForecast where
  parseJSON (Object o) =
    SimpleForecast <$> o .: "forecastday"
  parseJSON _ = mzero

instance FromJSON Forecast where
  parseJSON (Object o) =
    Forecast <$> o .: "simpleforecast"
  parseJSON _ = mzero

instance FromJSON ForecastResponse where
  parseJSON (Object o) =
    ForecastResponse <$> o .: "forecast"
  parseJSON _ = mzero

newtype ChanceOfPrecip = ChanceOfPrecip {
    percentage :: String
  } deriving Show

newtype Chance_Of = Chance_Of {
    chanceofprecip :: ChanceOfPrecip
  } deriving Show

newtype Trip = Trip {
    chance_of :: Chance_Of
  } deriving Show

newtype PlannerResponse = PlannerResponse {
    trip :: Trip
  } deriving Show

instance FromJSON ChanceOfPrecip where
  parseJSON (Object o) =
    ChanceOfPrecip <$> o .: "percentage"
  parseJSON _ = mzero

instance FromJSON Chance_Of where
  parseJSON (Object o) =
    Chance_Of <$> o .: "chanceofprecip"
  parseJSON _ = mzero

instance FromJSON Trip where
  parseJSON (Object o) =
    Trip <$> o .: "chance_of"
  parseJSON _ = mzero

instance FromJSON PlannerResponse where
  parseJSON (Object o) =
    PlannerResponse <$> o .: "trip"
  parseJSON _ = mzero

wuApiKey :: String
wuApiKey
  = "323c0323a2c78fcd"

secretKey :: SecKey
-- "secret"
secretKey
  = fromJust $ secKey $ Data.ByteString.Char8.pack
    "S6Qm57rWK0Ym2p2f1495tmMw16aydWvd"

wuApiRequest :: Network.HTTP.Simple.Request
wuApiRequest
  = setRequestHost "api.wunderground.com" defaultRequest

serverConfig :: ServerConfig
serverConfig
  = ServerConfig { Happstack.Lite.port = 8000
                 , ramQuota            = 1000000
                 , diskQuota           = 2000000
                 , tmpDir              = "/tmp/"
                 }

main :: IO()
main
  = serve (Just serverConfig) wethereumServer

wethereumServer :: ServerPart Happstack.Lite.Response
-- INPUT FORMAT: url:8000/timeInsuredFor/latitude/longitude/initialAmount
-- OUTPUT FORMAT: payout,initialAmount,latitude,longitude,timeInsuredFor,currentTime,hash
wethereumServer
  = dir "api"
    $ path $ \(timeInsuredFor :: Int) ->
      path $ \(latitude :: String) ->
      path $ \(longitude :: String) ->
      path $ \(initialAmount :: Int) ->
    do
      payout <- liftIO $ fmap show (calculatePayout timeInsuredFor latitude longitude initialAmount)
      currentTime <- liftIO $ fmap show getPOSIXTime
      let returnString = getReturnString [payout, show initialAmount, latitude, longitude,
                          show timeInsuredFor, Prelude.takeWhile isDigit currentTime]
      ok $ toResponse (returnString  :: String)

getReturnString :: [String] -> String
getReturnString inputs
  = withoutHash ++ "," ++ hashString
  where
    withoutHash = Data.List.intercalate "," inputs
    withoutHashBS = fromJust $ msg $ hash $ Data.ByteString.Char8.pack withoutHash
    hashString = Data.ByteString.Char8.unpack $ exportSig $ signMsg secretKey withoutHashBS

calculatePayout :: Int -> String -> String -> Int -> IO Int
calculatePayout unixTimestamp latitude longitude value
  = do
      prob <- getPrecipProb unixTimestamp latitude longitude
      return $ round ((fromIntegral value - 50000000000000000.0) * 100.0
        / (100.0 - (0.9 * fromIntegral prob)) :: Float)

getPrecipProb :: Int -> String -> String -> IO Int
getPrecipProb unixTimestamp latitude longitude
  = do
      timeDifference <- fmap (flip subtract (unixTimestamp - unixTimestamp `mod` 86400) . round)
                        (liftIO getPOSIXTime)
      if timeDifference < 10 * 86400
        then getPredictedPrecipProb unixTimestamp latitude longitude
        else getAveragePrecipProb unixTimestamp latitude longitude

getPredictedPrecipProb :: Int -> String -> String -> IO Int
getPredictedPrecipProb unixTimestamp latitude longitude
  = do
      response <- httpLBS $ setRequestPath apiPath wuApiRequest
      let body = getResponseBody response
      let forecastJson = fromJust (decode body :: Maybe ForecastResponse)
      let forecastDays = Prelude.map pop (forecastday (simpleforecast (forecast forecastJson)))
      getThisPrediction unixTimestamp forecastDays
      where
        apiPath = Data.ByteString.Char8.pack ("/api/" ++ wuApiKey
               ++ "/forecast10day/q/" ++ latitude ++ "," ++ longitude ++ ".json")

getThisPrediction :: Int -> [Int] -> IO Int
getThisPrediction unixTimestamp forecastDays
  = do
      timeDifference <- fmap (flip subtract (unixTimestamp - unixTimestamp `mod` 86400) . round)
                        (liftIO getPOSIXTime)
      return (forecastDays !! (timeDifference `div` 86400))

getAveragePrecipProb :: Int -> String -> String -> IO Int
getAveragePrecipProb unixTimestamp latitude longitude
  = do
      response <- httpLBS $ setRequestPath apiPath wuApiRequest
      let body = getResponseBody response
      let plannerJson = fromJust (decode body :: Maybe PlannerResponse)
      return (read $ percentage (chanceofprecip (chance_of (trip plannerJson))))
      where
        apiPath = Data.ByteString.Char8.pack ("/api/" ++ wuApiKey
               ++ "/planner_" ++ showUnixTimestamp unixTimestamp ++ "/q/"
               ++ latitude ++ "," ++ longitude ++ ".json")

showUnixTimestamp :: Int -> String
showUnixTimestamp unixTimestamp
  = formatTime defaultTimeLocale "%m%d%m%d"
    (posixSecondsToUTCTime $ fromIntegral unixTimestamp)
