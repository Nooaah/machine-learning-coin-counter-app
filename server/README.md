# CoinCounter

My own model trained to recognize French coins available here : https://bit.ly/3gskO4k

```bash
# Run server
python3 -B server.py
# Send file with POST method in another terminal
curl -F "file=@/Users/noahchatelain/Desktop/Projet_CoinCounter/server/src/image_test.jpg" 127.0.0.1:5000/send_image
```
