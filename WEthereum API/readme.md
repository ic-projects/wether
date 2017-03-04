# Wethereum API

Haskell based API that returns a payout for weather insurance.

## Usage

### Setup

Run the command `runghc server.hs`. Requires Haskell.

#### Personal Setup

- This API requires a WeatherUnderground API key. A developer key, with a limited number of requests per day is available for free on the WUnderground website. You will need to edit `server.hs` so that `wuApiKey` refers to your key.
- Set `secretKey` to your own (actually secret) secret 256 bit key.
- Set `Happstack.Lite.port` to the port of your choice. Change `8000` in the url provided to your chosen port.
- In `calculatePayout`, change the transaction fee from `50000000000000000` to your own transaction fee.
- In `calculatePayout`, change the payout amount from `0.9` to your own payout amount. This number must be less than 1. Decreasing the value reduces the payout, increasing your cut.

### Input

Queries are made to `url:8000/api/timeInsuredFor/latitude/longitude/initialAmout` where:

- `timeInsuredFor` is a unix timestamp of the format `1234567890`. It must refer to a time in the future (i.e. it must be a positive numerical value greater than the current number of seconds since 1st January 1970), otherwise no response is provided by the server.
- `latitude` is a signed numerical value between -180 and +180. E.g. `51.5074`. Value is in degrees. Positive means North, negative means South.
- `longitude` is a signed numerical value between -180 and +180. E.g. `-0.1278`. Value is in degrees. Positive means East, negative means West.
- `initialAmount` is a positive integer. E.g. `1000000000000000000`. It gives the initial insurance payment. The intended currency is wei (the smallest unit of Ether).

Example: `url:8000/api/1234567890/51.5074/-0.1278/1000000000000000000` represents an insurance contract, requested for the 13th February 2009, in London (51.5074° N, 0.1278° W), with an initial payment of 1 Ether. (Note that this is not a valid input, however, as the date is in the past).

#### Important Input Requirements

- The timestamp provided must be in the future, or no response will be given.
- In certain cases, if the coordinates are too far from an airport weather station, no response will be given.

### Ouput

Outputs are given in the format `payout,initialAmount,latitude,longitude,timeInsuredFor,currentTime,hash` where:

- `payout` is the fair payout calculated by the API. The intended currency is wei. The payout calculation deducts a cut of 50000000000000000 units (equivalent to 0.05 ether in the intended currency) to cover transaction fees, and then calculates a payout based on the probability of precipitation, taking a further cut which is equivalent to a 10% cut in the probability.
- `initialAmount` is the input `initialAmount`.
- `latitude` is the input `latitude`.
- `longitude` is the input `longitude`.
- `timeInsuredFor` is the input `timeInsuredFor`.
- `currentTime` is the current unix timestamp, truncated to an integral value.
- `hash` is a secp256k1 signature based on a sha256 hash of all of the data which precedes it (i.e. `payout,initialAmount,latitude,longitude,timeInsuredFor,currentTime,hash` - note that it includes all commas except the final one).

#### Probability Calculation

If the date to insure for is within 10 days of the current date, a forecasted probability is used. Otherwise, the probability is determined from historical values.
