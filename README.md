# Carets

Carets is a Rails engine that can retrieve, parse and send Zipkin information to a Zipkin server.

It is meant to be used together with the logger tracer in the Zipkin Ruby client.

The client would write tracing information in the logs. Sumologic will gather all that information together and Carets will search it and send it to Zipkin.

The benefit of doing this is that Carets can do any processing on that information, like expanding names of services. Also there is no need of having network traffic from every server to the zipkin server.


## Naming

Carets is an anagram of Traces