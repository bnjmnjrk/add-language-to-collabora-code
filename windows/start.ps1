Invoke-WebRequest -UseBasicParsing -OutFile soblex.zip https://soblex.de/spellchecker_extension_update/soblex_hsb_w6_3.06.00_16.02.2023_sc_th_hy.oxt
Expand-Archive soblex.zip -DestinationPath dict-so
Remove-Item soblex.zip

docker build -f dockerfile.collabora -t bnjmn/collabora .

Remove-Item -Recurse dict-so

docker run --rm -d -p 80:80 --name collabora_project_nextcloud nextcloud
docker run --rm -d -p 9980:9980 -e "extra_params=--o:ssl.enable=false" --name collabora_project_collabora bnjmn/collabora
