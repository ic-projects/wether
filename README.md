# wEther: Ethereum Weather Insurance
## Inspiration
We feel like you should be rewarded if you have to walk outside, but especially if it's raining. And in London, that's pretty much every other day.

## What It Does
It allows the user to insure themselves against bad weather (well, currently just against rain).

## How We Built It
We must have broken some kind of record in the number of APIs (at least ten!) we used on this project. Our email accounts were full of API keys by the end of the weekend!

We used the Yahoo Weather Api to get weather data for the front-end, and we built an API that scrapes weather websites and calculates payouts, in Haskell(?!).

The insurance uses smart contracts for Ethereum, written in Solidity, and we used Oraclize to validate the transaction.

## Challenges We Ran Into
Finding a weather api that gives us exactly what we needed - we spent like 6 hours Googling the options and in the end we found that none of them were suitable.

Working out a risk algorithm that was fair to both sides using the data we could get hold of.

Writing web-stuff in Haskell was super tough (we started as a joke), but it was definitely a good learning experience!

Turns out Solidity is pretty difficult to use too - it doesn't support most of the functionality you expect in a basic high-level language! We also ran into some concurrency issues - because we had to use the Web3 library to call Solidity methods in the Ethereum network.

We had one Git nightmare, but luckily we were able to recover pretty quickly.

## Accomplishments That We're Proud Of
Getting all the components to communicate with each other.

## What We Learned
That floats don't exist in solidity. :(

## What's Next For wEther
Changing the world, fixing everything. Insuring against low and high temperatures?

