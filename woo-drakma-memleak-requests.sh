#!/bin/sh

for i in {1..10000}; do curl -m 1 http://localhost:3000/api/test-mem-leak; done
