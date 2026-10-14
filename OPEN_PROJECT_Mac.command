#!/bin/bash
cd "$(dirname "$0")/site"
(sleep 1; open "http://localhost:8642/index.html") &
echo "Проект открыт: http://localhost:8642/  Чтобы остановить, закройте окно."
python3 -m http.server 8642
