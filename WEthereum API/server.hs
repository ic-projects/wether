{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}

module Main where

import Happstack.Lite
import Control.Monad.IO.Class
import Data.Time.Clock.POSIX
import Data.Time.Format
import Network.HTTP.Simple
import Data.Aeson
import Data.ByteString.Char8
import Data.ByteString.Lazy.Char8
import Data.Maybe

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
wethereumServer
  = dir "api"
    $ path $ \(unixTimestamp :: Int) ->
      path $ \(longitude :: String) ->
      path $ \(latitude :: String) ->
      path $ \(value :: Int) ->
    do
      payout <- liftIO $ fmap show (calculatePayout unixTimestamp longitude latitude value)
      ok $ toResponse ("{\"value\": " ++ payout ++ "}" :: String)

calculatePayout :: Int -> String -> String -> Int -> IO Int
calculatePayout unixTimestamp longitude latitude value
  = do
      prob <- getPrecipProb unixTimestamp longitude latitude
      return $ round (fromIntegral value - 50000000000000000.0 * 100.0
        / (100.0 - (9.0 / 10.0 * fromIntegral prob)) :: Float)

getPrecipProb :: Int -> String -> String -> IO Int
getPrecipProb unixTimestamp longitude latitude
  = do
      timeDifference <- fmap (subtract unixTimestamp . round) (liftIO getPOSIXTime)
      if timeDifference < 10 * 86400
        then getPredictedPrecipProb unixTimestamp longitude latitude
        else getAveragePrecipProb unixTimestamp longitude latitude

getPredictedPrecipProb :: Int -> String -> String -> IO Int
getPredictedPrecipProb unixTimestamp longitude latitude
  = do
      response <- httpLBS $ setRequestPath apiPath wuApiRequest
      let body = getResponseBody response
      let forecastJson = fromJust (decode body :: Maybe ForecastResponse)
      let forecastDays = Prelude.map pop (forecastday (simpleforecast (forecast forecastJson)))
      getThisPrediction unixTimestamp forecastDays
      where
        apiPath = Data.ByteString.Char8.pack ("/api/" ++ wuApiKey
               ++ "/forecast10day/q/" ++ longitude ++ "," ++ latitude ++ ".json")

getThisPrediction :: Int -> [Int] -> IO Int
getThisPrediction unixTimestamp forecastDays
  = do
      timeDifference <- fmap (flip subtract unixTimestamp . round) (liftIO getPOSIXTime)
      print timeDifference
      return (forecastDays !! (timeDifference `div` 86400))

getAveragePrecipProb :: Int -> String -> String -> IO Int
getAveragePrecipProb unixTimestamp longitude latitude
  = do
    response <- httpLBS $ setRequestPath apiPath wuApiRequest
    let body = getResponseBody response
    let plannerJson = fromJust (decode body :: Maybe PlannerResponse)
    return (read $ percentage (chanceofprecip (chance_of (trip plannerJson))))
    where
      apiPath = Data.ByteString.Char8.pack ("/api/" ++ wuApiKey
             ++ "/planner_" ++ showUnixTimestamp unixTimestamp ++ "/q/"
             ++ longitude ++ "," ++ latitude ++ ".json")

showUnixTimestamp :: Int -> String
showUnixTimestamp unixTimestamp
  = formatTime defaultTimeLocale "%m%d%m%d"
    (posixSecondsToUTCTime $ fromIntegral unixTimestamp)
