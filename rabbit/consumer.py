#!/usr/bin/env python3
# coding=utf-8
import pika

credentials = pika.PlainCredentials('pavel', 'pavel123')
params = pika.ConnectionParameters(
    host='158.160.185.69',
    port=5672,
    virtual_host='/',
    credentials=credentials
)

connection = pika.BlockingConnection(params)
channel = connection.channel()
channel.queue_declare(queue='hello')

def callback(ch, method, properties, body):
    print(" [x] Received %r" % body)

channel.basic_consume(queue='hello', on_message_callback=callback, auto_ack=True)
channel.start_consuming()
