#! /bin/bash
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y apache2


myip = `curl http://169.254.169.254/latest/meta-data/local-ipv4`
cat <<EOF > /var/www/html/index.html
<html>
<head>
</head>
<body>
<h1>KN-218</h2>
<h2>Nazar Mykhailiv</h3>
</body>
</html>
EOF

sudo systemctl start apache2
sudo systemctl enable apache2


