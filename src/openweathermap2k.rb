#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'kafka'

@name = "openweathermap2k"
# Defaults to Seville ;-)
lat = ENV['LATITUDE'].nil? ? "37.39" : ENV['LATITUDE']
lon = ENV['LONGITUDE'].nil? ? "-5.96" : ENV['LONGITUDE']
apikey = ENV['APIKEY']
url = ENV['URL'].nil? ? "http://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=#{lon}&units=metric&appid=#{apikey}" : ENV['URL']
@time = ENV['TIME'].nil? ? 900 : ENV['TIME'].to_i # minimun 10 minutes, defaults to 15 minutes
@time = 600 if @time < 600
kafka_broker = ENV['KAFKA_BROKER'].nil? ? "127.0.0.1" : ENV['KAFKA_BROKER']
kafka_port = ENV['KAFKA_PORT'].nil? ? "9092" : ENV['KAFKA_PORT']
@kafka_topic = ENV['KAFKA_TOPIC'].nil? ? "openweathermap" : ENV['KAFKA_TOPIC']
kclient = Kafka.new(seed_brokers: ["#{kafka_broker}:#{kafka_port}"], client_id: "openweathermap2k")

def w2k(url,kclient)
    puts "[#{@name}] Starting openweathermap thread"
    while true
        begin
            puts "[#{@name}] Connecting to #{url}" unless ENV['DEBUG'].nil?
            openw = Net::HTTP.get(URI(url))
            openwhash = JSON.parse(openw)
            openwhash["timestamp"] = Time.now.to_i
            puts "openweathermap event: #{openwhash.to_json}\n" unless ENV['DEBUG'].nil?
            kclient.deliver_message("#{openwhash.to_json}",topic: @kafka_topic)
            sleep @time
        rescue Exception => e
            puts "Exception: #{e.message}"
        end
    end

end


Signal.trap('INT') { throw :sigint }

catch :sigint do
        t1 = Thread.new{w2k(url,kclient)}
        t1.join
end

puts "Exiting from openweathermap2"

## vim:ts=4:sw=4:expandtab:ai:nowrap:formatoptions=croqln:
