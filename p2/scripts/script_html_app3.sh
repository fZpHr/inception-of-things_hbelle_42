#!/bin/bash

# Obtenir le nom du pod à partir des variables d'environnement
POD_NAME=$(hostname)

# Obtenir la version du système d'exploitation à l'intérieur du pod
VERSION=$(uname -a | awk '{for (i=6; i<NF; i++) printf $i " "; print ""}')

# Créer le répertoire s'il n'existe pas
if [ ! -d /usr/share/nginx/html ]; then
    mkdir -p /usr/share/nginx/html
fi

if [ -f /usr/share/nginx/html/index.html ]; then
    rm /usr/share/nginx/html/index.html
fi

sh -c "cat <<EOF > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>Kubernetes App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #333333;
            color: #e0e0e0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
        }
        .header {
            display: flex;
            align-items: center;
            margin-bottom: 80px;
            margin-top: -200px;
        }
        .header img {
            width: 100px;
            height: 100px;
            margin-right: 10px;
        }
        .header h1 {
            font-size: 100px;
            margin: 0;
            color: #ffffff;
        }
        .separator {
            width: 100%;
            border-bottom: 1px solid #ffffff;
            margin: 0;
        }
        .message {
            font-size: 70px;
            margin: 0;
            background-color: #444444;
            padding: 60px;
            border-radius: 0;
            width: 100%;
            text-align: center;
            border-bottom: 2px solid #ffffff;
            margin-bottom: 80px;
        }
        .info-container {
            width: 500px;
            text-align: left;
        }
        .info {
            margin-bottom: 10px;
        }
        .info strong {
            color: #ffffff;
            padding-right: 20px;
            display: inline-block;
            width: 80px;
        }
    </style>
</head>
<body>
    <div class=\"header\">
        <img src=\"https://upload.wikimedia.org/wikipedia/commons/3/39/Kubernetes_logo_without_workmark.svg\" alt=\"Kubernetes Icon\">
        <h1>kubernetes</h1>
    </div>
    <div class=\"separator\"></div>
    <div class=\"message\">Hello from app3.</div>
    <div class=\"info-container\">
        <div class=\"info\">
            <strong>pod:</strong> $POD_NAME
        </div>
        <div class=\"info\">
            <strong>node:</strong> $VERSION
        </div>
    </div>
</body>
</html>
EOF"
