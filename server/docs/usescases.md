the Satori Server serves 2 main purposes:

1. PUB/SUB: a free centralized pub sub service as an alternative to decentralized Streamr which has a cost.
2. Bad Actor POLICE: a service that keeps out bad actors for the public good offering.

------------------------------

required features:

PUB/SUB:
- clients must be able to set up streams to publish to
- clients must be able to publish observations to streams previously setup
- clients must be able to subscribe to streams (and get published observationed pushed to them in real-time)
- clients must be able to query the history of a stream by target and wallet (all observations assoicated with it)
- clients must be able to get a list of available streams (and metadata about them)
- clients must be able to query the structure of the subscriber network (get the subscriber map) 

POLICE:
- the server is in charge of which streams are "sanctioned" (which streams are eligible for clients to earn SATORI tokens by predicting them)
- the server is in charge of who predicts which streams (it's random)
- the server is in charge of (calculating each client's earnings)

shared:
- clients must be able to authenticate automatically (all of this is automatic without any user interaction required).

------------------------------

ENDPONTS:
WALLET AUTHENTICATION
when the client starts up it authenticates with the server by giving its authentication payload (message, signature, public key). If the public key has never been seen before the server saves it as a wallet record, as yet unassociated with a user ID (unless that's supplied too). 

SET UP DEVICE
The client sends it's capabilities payload (name of device, available ram in gigs, cpu speed in ghz, disk space in gigs, and bandwidth in Mbps down, or null for bandwidth, it's only really necessary when it's known to be limited) to the device endpoint and the server sets up a device record pointing to the wallet. It responds with a number of streams that the client should subscribe to and predict on. The streams are identified by source name, wallet public key that publishes the stream, stream name, and target id. If it is a weak computer 1 stream with a slow cadence is provided, If it has lots of resources including bandwidth, many streams with high cadence are provided. Most source streams are on streamr and therefore, the client is known to be subscribed to them on the server, but actually uses streamr to get the data. For each stream the client is told to subscribe to, a record is created for the wallet to predict on, that is, the server makes a predictive stream record that only that wallet can publish to, which corresponds to the source stream.

PUSH OBSERVATION
once a publish stream is setup (device endpoint) the client can publish observations to the stream. This means the client will speicify it's public key if that information is not already in the session or connection, the stream it wishes to publish to, the target it wishes to publish to, and the actual value it wishes to publish. That actual value, along with a reference to the stream, a reference to the target, and a reference to the wallet is then saved as a record to the observations table.

SUBSCRIBE TO STREAM
clients can subscribe to any stream they like (perhaps there's some limitation on the number of streams any one device can subscribe to for ddos considerations). Clients will send a subscribe payload which specifies their which device will be subscribing (must be a device their public key owns), the source, wallet, stream, and target they wish to subscribe to. Since stream names are not unique the wallet must be specified in order to know which stream exactly is referenced. First of all if the source is streamr or anything other than satori that means the client is merely reporting which stream they have subscribed to, in that case the server makes a record of that and no other action is required. If the source is satori, on the other hand, again, the server makes a record of it in the subscribers table, referencing the device, stream, and target, but this record, since it is pointing to a satori stream has an effect: any time there is an observation record (referencing that stream and target) saved it is also pushed to all the subscribers of this stream in real-time. If the subscribers are not active, it is not queued for when they become active, instead they will query the history themselves using the next endpoint.

GET HISTORY
clients will need to query the history of a stream for various purposes, the two main ones being, they were offline for some time and need to catch up, and more often, they are searching for a stream correlated with a stream they are predicting and therefore want part or all of it's history to analyze it for correlations before actually subscribing to it in order continually get updated. This endpoint will probably make use of the graphql features since the client will want to query the data for a certain interval of time, usually from the present to a certain moment in the past, and they want to get these records in chronological order. They will be querying Observations in order to get History.

GET STREAMS
clients will want to know which streams they can subscribe to, therefore they must use graphql to query the streams and targets table. metadata such as cadence and information about what kind of data the stream is reporting on, and if it's a predictive stream or not will be useful too.

GET SUBSCRIBER MAP
clients will also use graphql to query the map of subscribers (who subscribes to what). they will do this to make a recommender system that will tell them what they might want to subscribe to based on others that subscribe to similar things they do.

GET RANK
clients should be able to query their rank, so we can show it in the UI.

--------------------------------

**note: I think it would make things simple if we enforced the rule of one device to one wallet. Then clients couldn't say the same device is actually multiple devices. we close that vector of attack.

--------------------------------

logic:

overview: deciding which streams deserve how many predictors, and deciding which clients (or devices) have what rank is, probably the two most complex forms of logic the server must handle. Here we are focused on MVP versions of this logic, but MVP is far, far from ideal, there will be lots of room for improvement over time.

STREAM POPULARITY WEIGHT
popular streams should get more predictors. How do we determine which streams are popular? idk. we will have to do research on what kinds of metrics we can get about that. for now, however, to start with we'll just have 3 predictors per sanctioned stream. done. remember, each client device should be able to handle an average of at least 3 streams.

RANK
To keep out bad actors rank will have to get more complex over time but it's basic idea is to value accuracy and responsiveness. Luckily, we don't have to evaluate accuracy overtime. But the volture problem is real: if I'm predicting the price of btc with two others and they each publish a prediction before me, I may wish to view their answers and use their input to make a better prediction than each, and if I don't find their information useful I may wish to wait for other streams before predicting. To solve this problem we value responsiveness, giving the first person to respond more rank weight, but by doing so we introduce a new problem, even if I haven't made a prediction I get a guaranteed return if I just be the first one to respond. I don't like being forced to do a balancing act, I'd like to find a pure logical solution but for now we'll have to make the MVP with some economic heuristics. I think the MVP also needs to take into consideration the amount of effort it takes to calculate rank so we should only slightly reward or push responsiveness. and accuracy should also be a gold, silver, bronze type solution, on top of this we should have a series of checks to see if the client is adding any predictive value overtime. If they are not they will be removed from predicting that stream. So, assuming that only 3 predictors are on a stream, the first to predict should get 40% of the weight, the second should get 35% and the slowest should get 25% of the weight, same goes for accuracy. If the value turns out to be 100, the most accurate client predicted 99 they'd get 40% of the accuracy weight, if the 2nd closest predicted another predicted 98.99999, they'd get 35% and another predicted 600 the client that predicted the bogus 600 still will get 25% of the accuracy weight, but if his predictions are always bogus, he wont be able to predict a stream for long. Along with that, it should take at least a day of predicting on an hourly stream (24 observations) to start to gain any value from it whatsoever. That way bad actors will usually get weeded out during that period. I believe this set of heuristics is good enough for MVP as most people will simply download the software and run it, rather than put in the effort required to game the system. 

MINTING TOKENS
Another consideration for rank is cadence. Those that are predicting on a daily stream are doing just as much work as those that are predicting on a stream with a new observation every minute. Their cycles or "bandwidth" is being expended in the CPU by making new models and in actual bandwidth by finding correlated datstreams. So each stream, regardless of the cadence should get paid the same amount. Therefore, since X satori tokens get released every day each sanction stream should acrue tokens at the same rate and upon an actual observation, the ranking calcuations should take place and the amount that has been accrued by the stream should be distributed to it's predictors according to rank. in order to reduce transaction fees distributions should happen once a week or at most often once a day.