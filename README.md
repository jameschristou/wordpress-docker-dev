# wordpress-docker-dev
Docker file &amp; compose for setting up full wordpress dev environment capable of debugging with VSCode and XDebug

## Prerequisites
* [Docker](https://www.docker.com/)
* [docker-compose](https://docs.docker.com/compose/)
* [Visual Studio Code](https://code.visualstudio.com/)
* PHP Debug Extension for Visual Studio Code
* PHP Extension Pack for Visual Studio Code
* PHP Intellisense for Visual Studio Code

## Setup to Debug with VSCode
1. Create docker image using command `docker build -t jamesc/wordpressdev-php7.2 .`
2. Copy `docker-compose.yml` to folder where you wish to have the files mounted
3. Modify the volume mount config for the `wordpress_dev` service in `docker-compose.yml` to your requirements. If you want the entire Wordpress source mounted then leave as is.
4. Run docker compose using the command `docker-compose -f docker-compose.yml up`. This will start the Wordpress and MySQL containers.
5. Open the Wordpress source in Visual Studio Code (Open Folder)
6. Go to Debug->Open Configurations and select PHP (you must have the PHP Debug extension installed). Ensure the configuration looks something like this. The pathMappings setting may need to be modified
```
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for XDebug",
            "type": "php",
            "request": "launch",
            "port": 9000,
            "pathMappings": {
                "/var/www/html": "${workspaceFolder}"
            },
        },
        {
            "name": "Launch currently open script",
            "type": "php",
            "request": "launch",
            "program": "${file}",
            "cwd": "${fileDirname}",
            "port": 9000
        }
    ]
}
```
7. Now you can debug! Add a breakpoint, run some code and then watch the magic happen!

## Querying the MySQL DB
I did not include `phpMyAdmin` in the docker compose because I find it such a painful tool to use. For dev, I prefer to use something like [HeidiSQL](https://www.heidisql.com/download.php) or whatever your favourite client side MySQL tool is.

## Troubleshooting
XDebug
* Run `phpinfo()` to see the current settings for xdebug and confirm these are correct.
* Confirm that Visual Studio Code is listening to the correct port
* Turn on logging from xdebug on the docker container and examine the log. You can do this by adding `xdebug.remote_log=/usr/local/etc/php/xdebug.log` to the docker file.