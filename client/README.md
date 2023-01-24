# Satori
_A Future Network_

To the end user, Satori is a network they can join as a node by downloading a program and running it. Every node finds a primary data stream(s) to predict the future of and they work together to produce the best predictions possible. Every data stream that is consumed by the Satori network has a forecast that can be queried as a public good.

## Current State

Satori is a work in progress. It involves 3 major components:

1. the use of a pub-sub network
2. a blockchain for bounty and subscriber tracking
3. a node/miner: houses the automated prediction engine

So far, the automated prediction engine is the only component with any valuable work done on it, and most of it is prototypical. Still, that represents progress towards the goal.

### Automated Prediction Engine

The automated prediction engine is made of mainly two parts: the DataManager and a ModelManager.

A ModelManager builds models that predict the future of one particular datastream. They may consume more than one datastream to help them predict, but their prediction is always aimed at one datastream. They constantly train and retrain models, searching for the best one to predict the future of the datastream. (This essentially comes down to automated feature engineering, selection and hyperparameter tuning).

The DataManager is in charge of getting data for the ModelManager(s). This includes getting updates for all (primary) streams that are predicted by the ModelManager(s) and getting updates on all (secondary) streams they use to help them predict. Aside from getting updates, the DataManager also searches for potentially useful datastreams, downloads their histories, and notifies the ModelManager(s) so they can further evaluate the candidate streams.

## Simplifying Assumptions

Datastreams should have a simple format and a unique identity. They should have a time column (when the observation took place), and a value column (what the observation was). Using the pub-sub network, or the blockchain, metadata could be saved to describe each datastream. Metadata is not yet primarily relied upon by the system so its format should be a simple json structure. The datetime column could be called 'dt' 'datetime' 'time' or 'date', while the value column should be called 'observation' 'value' or the same as the streams unique identifier. The datetime column should support multiple formats, but UTC time should be preferred in order to easily merge datasets on the correct timing.

ModelManagers produce a prediction of the future, specifically the immediate future, the next timestep. This may sound like a limiting factor, as it seems to be a limit on versatility. However, producing a forecast of multiple observations into the future creates a substantial amount of complexity for the rest of the system. We can push that complexity into a simple structure: have multiple datastreams describing the same data on various timescales: hourly, daily, monthly, etc. With this design, to get a mid- or long-term forecast one merely needs to query multiple predictors.

Speaking of querying predictors, predictors are never literally queried. Instead each predictor (every ModelManager) produces a new datastream of their predictions. In this way their predictions become a freely accessible public good by default, as well as automatically becoming a new datastream other nodes can use in their own models.

## How to get involved

Review the code, feel free to submit pull requests, review the issues for things that need to be done.

### Social 

- http://www.satorinet.io
- https://www.reddit.com/r/SatoriNetwork

### Green Fields

There are a lot of minor components to the system that are not yet even started, as well as major components.

The connection to a pub sub network has not been explored. The Streamr network or Ocean protocol seem like good candidates.

The underlying DLT (blockchain) has not been designed.

As far as ML related things, an extra set of eyes on the practices employed thus far would be very useful. We're solely using the XGBoost regressor as a prototype because it works well and is easily automated and trains quickly. However, the final product would probably benefit by a broader view of automated ML procedures. Improving the current Model Manager or even building an alternative automated ML prediction engine would also be useful.

### how to install

```
> python setup.py develop
```
