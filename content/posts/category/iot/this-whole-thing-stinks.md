---
title: "This Whole Thing Stinks!"
Date: 2020-03-11
Author: davidgs
Category: Gadgetry, IoT
Tags: InfluxData, InfluxDB, IoT, Poop Detector
Slug: this-whole-thing-stinks
---

First of all, don't ask
-----------------------

I have no idea where this idea came from, it just happened. I keep saying "I'm not especially proud of this" but in reality? I sort of am because it's funny as shit (pun intended). Some projects came across my twitter feed that included (I shit you not) a 3-D printable model of the 💩 emoji. I remember nothing else about that project, but you'd better believe that I went straight for that STL file!

![Singing poop emoji](https://davidgs.com/wp-content/uploads/2020/03/singing-poop-emoji.jpg "singing-poop-emoji.jpg"){width="321" height="241"}

It then sat festering for a few weeks (if you're not comfortable with lots of shitty jokes, bail out now. Fair warning.). I knew I *would* do something with it, I just didn't know *what* I'd do. And then it hit me. I had a bunch of gas sensors lying around (if this surprises you, you really don't know me at all). And then it hit me! A bathroom stink sensor and alert system!! But my shit doesn't stink (shut up!) so where to deploy it? Eureka moment number 2! Our best friends' house, where all events are always held, has what we all call "The Hardest Working Bathroom in Holly Springs". There are regularly 20 people over there for dinner, or some other event, and that little powder room takes the brunt of it all.

Enter the Stink Detector
------------------------

First thing was to 3-D print the little shit. To make sure I could fit the proper LEDs in it to make it light up the way I want it to. And no, you cannot make anything light up brown. If you're *really* interested in why you can't make brown light, you can go watch [this video](https://youtu.be/wh4aWZRtTwU), but the dude is way weirder than I am. Again, fair warning. So anyway, I printed it, and lo and behold, the LED controller I wanted to use fit (almost) perfectly! I had to clip a couple of corners off the PCB, but no harm was done, and I got a light-up poop emoji!

![IMG 0087](https://davidgs.com/wp-content/uploads/2020/03/IMG_0087.jpeg "IMG_0087.jpeg"){width="225" height="300"}

I've also scaled it to 150% and I'm considering printing it that way just because, well, you know, bigger shit is better shit! So, how did I light this shit up? Actually, very simply. I buy these Wemos D1 Mini boards in bulk (like 20 at a time, since they're only $2.00 each -- more expensive if you buy them from Amazon, but if you buy them from Ali Express in China, they can be as cheap as $1.50 each) and I buy matching tri-color LED shields to go with them. My friends [Andy Stanford-Clark](https://twitter.com/andysc) got me started on these things with his 'Glow Orbs" If you want to read more on the specifics of Glow Orbs, [Dr. Lucy Rogers](https://twitter.com/DrLucyRogers) wrote a whole thing about them [here](https://www.ibm.com/blogs/internet-of-things/creating-home-glow-orb/). Turns out she built a Fart-O-Meter and used a GlowOrb as well. I had no idea until Andy told me.

For a Getting Started tutorial on the Wemos D1, see [this article](https://www.hackster.io/innovativetom/wemos-d1-mini-esp8266-getting-started-guide-with-arduino-727098). I know a lot of folks write up full, detailed tutorials, etc. for this stuff but, frankly, I'm too lazy so I mostly just tell you what I've done. I'll give the gory details where it matters.

So anyway, since I do this shit all the time, I have my poop-light listen to an MQTT broker for messages about what color to display. I'm still working out the detailed color levels as I calibrate things. I'll cover the specifics of how messages get sent and received in a bit.

The stink detector itself is also being run on a Wemos D1 Mini with an MQ-4 Methane sensor that also supposedly measures H2 and an SGP-30 Air Quality sensor that measures Volatile Organic Chemicals (VOCs) and a really shitty version of CO2 which should never be trusted. I've done a lot of work with CO2 sensors, and these eCO2 sensors aren't worth a shit. Seriously, never trust them. I'm awaiting delivery on some more, better gas sensors like an MQ-136 Sulphur Dioxide sensor and others. I'll likely deploy them all and then invent some complicated but entirely arbitrary algorithm for deciding what is 'smelly'. Stay tuned for that.

Building the Stink Sensor
-------------------------

As I said, I'm currently using a Wemos D1 Mini with an [MQ-4 Methane Sensor](https://www.sparkfun.com/products/9404) and an [SGP-30](https://www.adafruit.com/product/3709) air quality sensor. You can buy them yourself if you plan to build this thing. I'll update this with other sensors as I add them, maybe. Here's how to wire everything up:

![Stinker](https://davidgs.com/wp-content/uploads/2020/03/Stinker.png "Stinker.png"){width="521" height="310"}

It's important to note that the MQ-4 requires 5v whereas the SGP-30 only needs 3.3v. The MQ-4 is a straight analog sensor, so wiring it to one of the Analog inputs works fine. The SGP-30 is an I2C sensor, so it's wired SDA<-->D1 and SCL<-->D2 which are the default I2C pins on the Wemos (which I have to look up every single time). When you apply 5v via the USB the MQ-4 gets straight 5v and the SGP-30 gets 3.3v via the onboard voltage regulator. Now, how do you actually get data off of these sensors? Well, that's next, of course!

Reading Stink
-------------

The SGP-30 has a library for it provided by Adafruit (of course) so you'll need to add that library to your Arduino IDE and then include it in your project.

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[#include]{style="color: #4fd8a2;"} [<Adafruit_SGP30.h>]{style="color: #8e8e8e;"}
[#include]{style="color: #4fd8a2;"} [<Wire.h>]{style="color: #8e8e8e;"}
:::

You will then create and SGP30 object and initialize it in your setup routine:

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[Adafruit_SGP30 sgp;]{style="color: #8e8e8e;"}
:::

Creates the object and then:

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[if]{style="color: #4fd8a2;"} [(! sgp.]{style="color: #8e8e8e;"}[begin]{style="color: #aa661e;"}[()){]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[Serial]{style="color: #aa661e;"}[.]{style="color: #8e8e8e;"}[println]{style="color: #aa661e;"}[(]{style="color: #8e8e8e;"}["Sensor not found :("]{style="color: #3e90ef;"}[);]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[while]{style="color: #4fd8a2;"} [(1);]{style="color: #8e8e8e;"}
[}]{style="color: #8e8e8e;"}
:::

initializes the sensor. If you haven't wired the sensor correctly, the whole thing will hang, so make sure you've wired it up correctly!

Reading the VOC is pretty simple after that:

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[if]{style="color: #8e8e8e;"} [(! sgp.IAQmeasure()) {]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[Serial]{style="color: #aa661e;"}[.]{style="color: #8e8e8e;"}[println]{style="color: #aa661e;"}[("Measurement failed");]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[return;
}]{style="color: #8e8e8e;"}
[Serial.print]{style="color: #aa661e;"}[(]{style="color: #8e8e8e;"}["TVOC "]{style="color: #3e90ef;"}[);]{style="color: #8e8e8e;"} [Serial.print]{style="color: #aa661e;"}[(sgp.TVOC);]{style="color: #8e8e8e;"} [Serial.print]{style="color: #aa661e;"}[(]{style="color: #8e8e8e;"}[" 	"]{style="color: #3e90ef;"}[);]{style="color: #8e8e8e;"}
[Serial.print]{style="color: #aa661e;"}[(]{style="color: #8e8e8e;"}["Raw H2 "]{style="color: #3e90ef;"}[);]{style="color: #8e8e8e;"} [Serial.print]{style="color: #aa661e;"}[(sgp.rawH2);]{style="color: #8e8e8e;"} [Serial.print]{style="color: #aa661e;"}[(]{style="color: #8e8e8e;"}[" 	"]{style="color: #3e90ef;"}[);]{style="color: #8e8e8e;"}
[Serial.print]{style="color: #aa661e;"}[(]{style="color: #8e8e8e;"}["Raw Ethanol "]{style="color: #3e90ef;"}[);]{style="color: #8e8e8e;"} [Serial.print]{style="color: #aa661e;"}[(sgp.rawEthanol);]{style="color: #8e8e8e;"} [Serial.println]{style="color: #aa661e;"}[(]{style="color: #8e8e8e;"}[""]{style="color: #3e90ef;"}[);]{style="color: #8e8e8e;"}
:::

The sgp object is returned with all the readings in it, so it's pretty easy. The MQ-4 sensor is a little more tricky. It's an analog sensor, which means that it really just returns a raw voltage reading, which scales (somewhat) with the gas concentration. Lucky for me, someone provided a nice function to turn the raw voltage into a ppm (Parts Per Million) reading for the methane, so that's required as well:

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[int]{style="color: #3e90ef;"} [NG_ppm(double rawValue){]{style="color: #8e8e8e;"}

[    ]{style="color: #00ff00;"}[double]{style="color: #3e90ef;"} [ppm = 10.938*exp(1.7742*(rawValue*3.3/4095)); ]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[return ppm;
}]{style="color: #8e8e8e;"}
:::

Yeah, maths. I have no idea how it works, but it seems to, so I'm going with it because I'm shitty at math and have to trust someone smarter than me (which is most people, frankly). So now I can read the raw voltage on the analog pin, and then convert that to a reading of ppm, which is what we really want.

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[int]{style="color: #3e90ef;"} [sensorValue = analogRead(A0); // read analog input pin 0]{style="color: #8e8e8e;"}
[int]{style="color: #3e90ef;"} [ppm = NG_ppm(sensorValue);]{style="color: #8e8e8e;"}
:::

Cool! So, now that we can read the gas levels how do we tie all this together?

Don't Use A Shitty Database!
----------------------------

Of course I work for a database company, so we're going to use that one. Actually, even if I didn't work for this particular database company, I'd still use it because, for IoT data like this, it's just really the best solution. We will send all our data to InfluxDB and then we can see how to alert the glowing poop to change colors. So, how do we send data to InfluxDB? It's super simple. We use the InfluxDB library for Arduino, of course!

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[#include]{style="color: #4fd8a2;"} [<InfluxDb.h>]{style="color: #8e8e8e;"}
[#define]{style="color: #4fd8a2;"} [INFLUXDB_HOST ]{style="color: #8e8e8e;"}["yourhost.com"]{style="color: #3e90ef;"}
[#define ]{style="color: #4fd8a2;"}[INFLUX_TOKEN]{style="color: #8e8e8e;"} ["yourLongTokenStringForInfluxDB2"]{style="color: #3e90ef;"}
[#define]{style="color: #4fd8a2;"} [BATCH_SIZE]{style="color: #8e8e8e;"} [10]{style="color: #3e90ef;"}
[Influxdb]{style="color: #aa661e;"} [influx(INFLUXDB_HOST);]{style="color: #8e8e8e;"}
:::

A couple of things to note here. I'm using InfluxDB 2.0, which is why I need the token. I have defined a BATCH_SIZE because writing data is much more efficient if we do it in batches rather than individually. Why? Well, I'm glad you asked! Each write to the database happens over the HTTP protocol. So when you want to do that, you have to set up the connection, write the data, and then tear down the connection. Doing this every second or so is expensive, from a power and processor perspective. So it's better to save up a bunch of datapoints, then do the setup-send-teardown cycle once for all of it.

So now we have an Influxdb object initialized with the correct server address. In the setup() function we have to complete the configuration:

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[influx]{style="color: #aa661e;"}[.setBucket(]{style="color: #8e8e8e;"}["myBucket"]{style="color: #3e90ef;"}[);]{style="color: #8e8e8e;"}
[influx]{style="color: #aa661e;"}[.setVersion(2);]{style="color: #8e8e8e;"}
[influx]{style="color: #aa661e;"}[.setOrg(]{style="color: #8e8e8e;"}["MyOrg"]{style="color: #3e90ef;"}[);]{style="color: #8e8e8e;"}
[influx]{style="color: #aa661e;"}[.setPort(]{style="color: #8e8e8e;"}[9999]{style="color: #f95f53;"}[);]{style="color: #8e8e8e;"}
[influx]{style="color: #aa661e;"}[.setToken(INFLUX_TOKEN);]{style="color: #8e8e8e;"}
:::

That's literally it. I'm all set up to start writing data to InfluxDB, so let's see how I do that:

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[if]{style="color: #3e90ef;"} [(batchCount >= BATCH_SIZE) {]{style="color: #3e90ef;"}
[    ]{style="color: #00ff00;"}[influx]{style="color: #aa661e;"}[.write();]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[Serial]{style="color: #aa661e;"}[.]{style="color: #00ff00;"}[println]{style="color: #aa661e;"}[(]{style="color: #8e8e8e;"}["Wrote to InfluxDB"]{style="color: #3e90ef;"}[);]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[batchCount = ]{style="color: #8e8e8e;"}[0]{style="color: #f95f53;"}[;
}]{style="color: #8e8e8e;"}
[InfluxData]{style="color: #aa661e;"} [row(]{style="color: #8e8e8e;"}["bathroom"]{style="color: #3e90ef;"}[);]{style="color: #8e8e8e;"}
[row]{style="color: #aa661e;"}[.addTag(]{style="color: #8e8e8e;"}["location "]{style="color: #3e90ef;"}[,]{style="color: #8e8e8e;"} ["hsbath"]{style="color: #3e90ef;"}[);]{style="color: #8e8e8e;"}
[row]{style="color: #aa661e;"}[.addTag(]{style="color: #8e8e8e;"}["sensor1"]{style="color: #3e90ef;"}[,]{style="color: #8e8e8e;"} ["sgp30"]{style="color: #3e90ef;"}[);]{style="color: #8e8e8e;"}
[row]{style="color: #aa661e;"}[.addTag(]{style="color: #8e8e8e;"}["sensor2"]{style="color: #3e90ef;"}[,]{style="color: #8e8e8e;"} ["mq-4"]{style="color: #3e90ef;"}[);]{style="color: #8e8e8e;"}
[row]{style="color: #aa661e;"}[.addValue(]{style="color: #8e8e8e;"}["tvoc"]{style="color: #3e90ef;"}[, sgp.TVOC);]{style="color: #8e8e8e;"}
[row]{style="color: #aa661e;"}[.addValue(]{style="color: #8e8e8e;"}["raw_h2"]{style="color: #3e90ef;"}[, sgp.rawH2);]{style="color: #8e8e8e;"}
[row]{style="color: #aa661e;"}[.addValue(]{style="color: #8e8e8e;"}["ethanol"]{style="color: #3e90ef;"}[, sgp.rawEthanol);]{style="color: #8e8e8e;"}
[row]{style="color: #aa661e;"}[.addValue(]{style="color: #8e8e8e;"}["methane"]{style="color: #3e90ef;"}[, ppm);]{style="color: #8e8e8e;"}
[influx]{style="color: #aa661e;"}[.prepare(row);]{style="color: #8e8e8e;"}
[batchCount +=1;
delay(]{style="color: #8e8e8e;"}[500]{style="color: #f95f53;"}[);]{style="color: #8e8e8e;"}
:::

In the first part, I check to see if I'm up to my batch limit and if I am, I write the whole mess out to the database, and reset my count. After that, I create a new row for the database and add the tags and values to it. Then I 'prepare' the row which really just adds it to the queue to be written with the next batch. Increase the batch count, and sit quietly for 500ms (½ a second). Then we do the whole thing again.

Let's go to the database and see if I have it all working:

![Screen Shot 2020 03 11 at 2 55 28 PM](https://davidgs.com/wp-content/uploads/2020/03/Screen-Shot-2020-03-11-at-2.55.28-PM.png "Screen Shot 2020-03-11 at 2.55.28 PM.png"){width="939" height="600"}

I'd say that's a yes! Now that it's all there, it's time to send updates to the glowing poop!

For that, we're going to create a Task in InfluxDB 2.0. And I'm going to call it 'poop' because even I don't want a task called 'shit' in my UI.

![Screen Shot 2020 03 11 at 2 57 12 PM](https://davidgs.com/wp-content/uploads/2020/03/Screen-Shot-2020-03-11-at-2.57.12-PM.png "Screen Shot 2020-03-11 at 2.57.12 PM.png"){width="409" height="316"}

And here's the task I created:

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[import]{style="color: #8e8e8e;"} ["experimental/mqtt"]{style="color: #67ff7b;"}

[option]{style="color: #8e8e8e;"} [task]{style="color: #3e90ef;"} [=]{style="color: #e7efea;"} [{name: "poop", every: 30s}]{style="color: #817eff;"}

[from]{style="color: #817eff;"}[(]{style="color: #00ff00;"}[bucket: ]{style="color: #8e8e8e;"}["telegraf"]{style="color: #67ff7b;"}[)]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[|> range]{style="color: #817eff;"}[(start:]{style="color: #8e8e8e;"} -[task]{style="color: #f95f53;"}[.every)]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[|> filter]{style="color: #817eff;"}[(fn: (]{style="color: #8e8e8e;"}[r]{style="color: #f95f53;"}[)]{style="color: #8e8e8e;"} [=>]{style="color: #f95f53;"}
[        ]{style="color: #00ff00;"}[(]{style="color: #8e8e8e;"}[r]{style="color: #f95f53;"}[._measurement]{style="color: #8e8e8e;"} == ["bathroom"]{style="color: #67ff7b;"}[))]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[|> filter]{style="color: #817eff;"}[(fn: (]{style="color: #8e8e8e;"}[r]{style="color: #f95f53;"}[)]{style="color: #8e8e8e;"} [=>]{style="color: #f95f53;"}
[        ]{style="color: #00ff00;"}[(]{style="color: #8e8e8e;"}[r]{style="color: #f95f53;"}[._field]{style="color: #8e8e8e;"} == ["tvoc"]{style="color: #67ff7b;"}[))]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[|> last]{style="color: #817eff;"}[()]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[|>]{style="color: #817eff;"} [mqtt]{style="color: #f95f53;"}[.to]{style="color: #817eff;"}[(]{style="color: #8e8e8e;"}
[        ]{style="color: #00ff00;"}[broker:]{style="color: #8e8e8e;"} ["tcp://yourmqttbroker.com:8883"]{style="color: #67ff7b;"}[,]{style="color: #8e8e8e;"}
[        ]{style="color: #00ff00;"}[topic:]{style="color: #8e8e8e;"} ["poop"]{style="color: #67ff7b;"}[,]{style="color: #8e8e8e;"}
[        ]{style="color: #00ff00;"}[clientid:]{style="color: #8e8e8e;"} ["poop-flux"]{style="color: #67ff7b;"}[,]{style="color: #8e8e8e;"}
[       ]{style="color: #00ff00;"}[ valueColumns: []{style="color: #8e8e8e;"}["_value"]{style="color: #67ff7b;"}[],]{style="color: #8e8e8e;"}
[      ]{style="color: #00ff00;"}[)]{style="color: #8e8e8e;"}
:::

Since there's a lot going on there, I'll go through it all. First off, the MQTT package I wrote is still in the "experimental" package, so you have to import that in order to use it. If you look above in the image of the data explorer you can see that I'm storing everything in my "telegraf" bucket, and the "bathroom" measurement. Right now, I'm only keying off of the "tvoc" reading. Once I change that, I'll update this task with the formula that I use. I'm just grabbing the last reading over the past 30 seconds. I then fill out the details for the MQTT broker I am using, and the topic to submit to, and off it goes! That's it for the task!

Lighting Shit Up!
-----------------

So as you recall, we put a WEMOS D1 mini with a tri-color LED on it into the printed poop. Now it's time to light that shit up! Since we're writing values out to an MQTT broker, all we really need to do is connect that WEMOS to the MQTT broker, which, thankfully, is really straightforward.

You need a bunch of WiFi stuff (you also need this in the sensor code, by the way):

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[#include]{style="color: #4fd8a2;"}[ <ESP8266WiFi.h>]{style="color: #8e8e8e;"}
[#include]{style="color: #4fd8a2;"} [<DNSServer.h>]{style="color: #8e8e8e;"}
[#include]{style="color: #4fd8a2;"} [<ESP8266WebServer.h>]{style="color: #8e8e8e;"}
[#include]{style="color: #4fd8a2;"} [<WiFiManager.h>]{style="color: #8e8e8e;"}
[#include]{style="color: #4fd8a2;"} [<PubSubClient.h>]{style="color: #8e8e8e;"}
[#include]{style="color: #4fd8a2;"} [<Adafruit_NeoPixel.h>]{style="color: #8e8e8e;"}
[#include]{style="color: #4fd8a2;"} [<ESP8266mDNS.h>]{style="color: #8e8e8e;"}
[#include]{style="color: #4fd8a2;"} [<WiFiUdp.h>]{style="color: #8e8e8e;"}
:::

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
:::

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[#define]{style="color: #4fd8a2;"}[ LED_PIN D2 //12 //D2]{style="color: #8e8e8e;"}
[#define]{style="color: #4fd8a2;"}[ LED_COUNT 1]{style="color: #8e8e8e;"}
[// update this with the Broker address ]{style="color: #8e8e8e;"}
[#define]{style="color: #4fd8a2;"}[ BROKER ]{style="color: #8e8e8e;"}["mybroker.com"]{style="color: #3e90ef;"}
[// update this with the Client ID in the format d:{org_id}:{device_type}:{device_id}]{style="color: #8e8e8e;"}
[#define]{style="color: #4fd8a2;"}[ CLIENTID ]{style="color: #8e8e8e;"}["poop-orb"]{style="color: #3e90ef;"}
:::

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
:::

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[#define]{style="color: #4fd8a2;"} [COMMAND_TOPIC]{style="color: #8e8e8e;"}[ "poop"
int]{style="color: #3e90ef;"}[ status = WL_IDLE_STATUS; // the Wifi radio's status]{style="color: #8e8e8e;"}
[WiFiClient]{style="color: #aa661e;"} [espClient;]{style="color: #8e8e8e;"}
[PubSubClient]{style="color: #aa661e;"} [client(espClient);]{style="color: #8e8e8e;"}
:::

Some of these are things that also correspond to things in your InfluxDB Task, like the COMMAND_TOPIC, and the BROKER. so make sure you get those correct between the two. That's all the stuff you have to have defined (I'm not going through how to get the WiFi setup and configured as there are hundreds of tutorials on doing that for Arduino and ESP8266 devices.).

In your setup() function you will need to configure your MQTT Client (PubSubClient) object and subscribe to your topic as well as set up your LED. I use the Adafruit NeoPixel library because it's super easy to use.

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[client]{style="color: #aa661e;"}[.setServer(BROKER, ]{style="color: #8e8e8e;"}[8883]{style="color: #f95f53;"}[);]{style="color: #8e8e8e;"}
[client]{style="color: #aa661e;"}[.setCallback(callback);]{style="color: #8e8e8e;"}
:::

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[client]{style="color: #aa661e;"}[.subscribe(COMMAND_TOPIC);]{style="color: #8e8e8e;"}
:::

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[Adafruit_NeoPixel]{style="color: #3e90ef;"}[ pixel = Adafruit_NeoPixel(]{style="color: #8e8e8e;"}[1]{style="color: #f95f53;"}[, ]{style="color: #8e8e8e;"}[4]{style="color: #f95f53;"}[); // eight pixels, on pin 4
//pin 4 is "D2" on the WeMoS D1 mini]{style="color: #8e8e8e;"}
:::

Your main loop is pretty short for this, as the PubSubClient handles a lot of the timing for you:

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[void]{style="color: #3e90ef;"} [loop() {]{style="color: #8e8e8e;"}

[    ]{style="color: #00ff00;"}[if]{style="color: #3e90ef;"} [(!]{style="color: #8e8e8e;"}[client]{style="color: #aa661e;"}[.connected()) {
reconnect();
}
// service the MQTT client]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[client]{style="color: #aa661e;"}[.loop();
}]{style="color: #8e8e8e;"}
:::

You will, of course, need the callback routi, and this is where the magic happens, so let's look at that now.

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
[void]{style="color: #3e90ef;"} [callback(]{style="color: #8e8e8e;"}[char*]{style="color: #3e90ef;"} [topic,]{style="color: #8e8e8e;"} [byte*]{style="color: #3e90ef;"} [payload, unsigned]{style="color: #8e8e8e;"} [int]{style="color: #3e90ef;"} [length]{style="color: #aa661e;"}[) {]{style="color: #8e8e8e;"}
[char]{style="color: #3e90ef;"} [content[]{style="color: #8e8e8e;"}[10]{style="color: #f95f53;"}[];]{style="color: #8e8e8e;"}

[String]{style="color: #3e90ef;"} [s =]{style="color: #8e8e8e;"} [String]{style="color: #3e90ef;"}[((]{style="color: #8e8e8e;"}[char *]{style="color: #3e90ef;"}[)payload);]{style="color: #8e8e8e;"}
[s.trim();]{style="color: #8e8e8e;"}
[Serial]{style="color: #aa661e;"}[.]{style="color: #8e8e8e;"}[print]{style="color: #aa661e;"}[(]{style="color: #8e8e8e;"}["Message arrived on "]{style="color: #3e90ef;"}[);]{style="color: #8e8e8e;"}
[Serial]{style="color: #aa661e;"}[.]{style="color: #8e8e8e;"}[print]{style="color: #aa661e;"}[(COMMAND_TOPIC);]{style="color: #8e8e8e;"}
[Serial]{style="color: #aa661e;"}[.]{style="color: #8e8e8e;"}[print]{style="color: #aa661e;"}[(]{style="color: #8e8e8e;"}[": "]{style="color: #3e90ef;"}[);]{style="color: #8e8e8e;"}

[unsigned]{style="color: #8e8e8e;"} [char]{style="color: #3e90ef;"} [buff[]{style="color: #8e8e8e;"}[256]{style="color: #f95f53;"}[] {};]{style="color: #8e8e8e;"}
[s.getBytes(buff, ]{style="color: #8e8e8e;"}[256]{style="color: #f95f53;"}[);]{style="color: #8e8e8e;"}
[buff[]{style="color: #8e8e8e;"}[255]{style="color: #f95f53;"}[] = ]{style="color: #8e8e8e;"}[' ]{style="color: #aa661e;"}[';]{style="color: #8e8e8e;"}
[s = s.substring(s.indexOf(]{style="color: #8e8e8e;"}["="]{style="color: #3e90ef;"}[) +]{style="color: #8e8e8e;"} [1]{style="color: #f95f53;"}[, s.lastIndexOf(]{style="color: #8e8e8e;"}[" "]{style="color: #f95f53;"}[) );
s.trim();]{style="color: #8e8e8e;"}
[int]{style="color: #3e90ef;"} [c = s.toInt();]{style="color: #8e8e8e;"}
[String]{style="color: #3e90ef;"} [col =]{style="color: #8e8e8e;"} [""]{style="color: #3e90ef;"}[;]{style="color: #8e8e8e;"}
[if]{style="color: #4fd8a2;"} [(c > ]{style="color: #8e8e8e;"}[100.0]{style="color: #f95f53;"} [) {]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[col =]{style="color: #8e8e8e;"} ["ff0000"]{style="color: #3e90ef;"}[;]{style="color: #8e8e8e;"}
[}]{style="color: #8e8e8e;"} [else if]{style="color: #4fd8a2;"} [(c >]{style="color: #8e8e8e;"} [90.0]{style="color: #f95f53;"} [) {]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[col =]{style="color: #8e8e8e;"} ["ff4000"]{style="color: #3e90ef;"}[;]{style="color: #8e8e8e;"}
[} ]{style="color: #8e8e8e;"}[else if]{style="color: #4fd8a2;"} [(c >]{style="color: #8e8e8e;"} [80.0]{style="color: #f95f53;"} [) {]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[col = ]{style="color: #8e8e8e;"}["ffbf00"]{style="color: #3e90ef;"}[;]{style="color: #8e8e8e;"}
[}]{style="color: #8e8e8e;"} [else if]{style="color: #4fd8a2;"} [(c >]{style="color: #8e8e8e;"} [70.0]{style="color: #f95f53;"} [) {]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[col = ]{style="color: #8e8e8e;"}["bfff00"]{style="color: #3e90ef;"}[;]{style="color: #8e8e8e;"}
[}]{style="color: #8e8e8e;"} [else if]{style="color: #4fd8a2;"} [(c > ]{style="color: #8e8e8e;"}[60.0]{style="color: #f95f53;"} [) {]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[col = ]{style="color: #8e8e8e;"}["40ff00"]{style="color: #3e90ef;"}[;]{style="color: #8e8e8e;"}
[}]{style="color: #8e8e8e;"} [else if]{style="color: #4fd8a2;"} [(c > ]{style="color: #8e8e8e;"}[50.0]{style="color: #f95f53;"} [) {]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[col =]{style="color: #8e8e8e;"} ["00ff40"]{style="color: #3e90ef;"}[;]{style="color: #8e8e8e;"}
[}]{style="color: #8e8e8e;"} [else if]{style="color: #4fd8a2;"} [(c > ]{style="color: #8e8e8e;"}[40.0]{style="color: #f95f53;"} [) {]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[col =]{style="color: #8e8e8e;"} ["00ffbf"]{style="color: #3e90ef;"}[;]{style="color: #8e8e8e;"}
[}]{style="color: #8e8e8e;"} [else if]{style="color: #4fd8a2;"} [(c >]{style="color: #8e8e8e;"} [10.0]{style="color: #f95f53;"} [) {]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[col = ]{style="color: #8e8e8e;"}["00bfff"]{style="color: #3e90ef;"}[;]{style="color: #8e8e8e;"}
[}]{style="color: #8e8e8e;"} [else]{style="color: #4fd8a2;"} [{]{style="color: #8e8e8e;"}
[    ]{style="color: #00ff00;"}[col =]{style="color: #8e8e8e;"} ["bf00ff"]{style="color: #3e90ef;"}[;]{style="color: #8e8e8e;"}
[}]{style="color: #8e8e8e;"}

[long long]{style="color: #3e90ef;"} [number = strtoll(&col[]{style="color: #8e8e8e;"}[0]{style="color: #f95f53;"}[], NULL,]{style="color: #8e8e8e;"} [16]{style="color: #f95f53;"}[);]{style="color: #8e8e8e;"}
[int]{style="color: #3e90ef;"} [r = number >> ]{style="color: #8e8e8e;"}[16]{style="color: #f95f53;"}[;]{style="color: #8e8e8e;"}
[int]{style="color: #3e90ef;"} [g = number >>]{style="color: #8e8e8e;"} [8]{style="color: #f95f53;"} [&]{style="color: #8e8e8e;"} [0xFF;]{style="color: #8e8e8e;"}
[int]{style="color: #3e90ef;"} [b = number & 0xFF;]{style="color: #8e8e8e;"}
[uint32_t]{style="color: #3e90ef;"} [pCol =]{style="color: #8e8e8e;"} [pixel]{style="color: #aa661e;"}[.Color(r, g, b);]{style="color: #8e8e8e;"}
[colorWipe(pCol, ]{style="color: #8e8e8e;"}[100]{style="color: #f95f53;"}[);
}]{style="color: #8e8e8e;"}
:::

Yeah, it's nutty. Mostly because I use this same code in a bunch of different places. Sometimes I want the hex color, sometimes I want the RGB color, so I can go either way here. It looks shitty, but it works for me.  All this does is get the message from the MQTT broker, and pull out the numeric value (through experience, I know that the MQTT message comes in the following format:

::: {.terminal style="background-color: #000000; color: #00ff00; font-family: courier, monospace;"}
bathroom _value=566 1583959496007304541
:::

So I know I can index into it to the `=` sign and the ` ` (space character) and come back with the numeric value. From there, it's just scaling the value to the color and turning on the LED! After that, the poop glows when you shit! And the color changes depending on how stinky it is. The VOC value isn't really a very good value (especially if you tend to use some sort of poop-spray to hide your mis-deed. Most of those are nothing but VOCs and that will spike the numbers, Which is why I'm awaiting the new sensors so I can get lots of gas values and see which one is most indicative of stink. Or which ones, more accurately. After that I'll come up with some algorithm to properly scale the stink level based on the various gas levels. Then deploy to the Hardest Working Bathroom in Holly Springs.

And yes, they are game to have the stink-o-meter deployed over there.

Get your own shit
-----------------

So, if you want to build one yourself ... first you'll need to print your own shit. You can download the STL file [here](https://davidgs.com/poop.stl). I'll see if I can clean up all this code and put it in my [GitHub](https://github.com/davidgs). Feel free to [Follow Me](https://twitter.com/intent/follow?screen_name=davidgsIoT) on Twitter and reach out with questions or comments!

As a final word, please, for the love of all that's holy, wash your damned hands. 60% of men and 40% of women don't wash their hands after using the toilet and that is disgusting. And now it makes you a disease vector. So **Wash. Your. Hands!**
