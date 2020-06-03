## Usage

Preferably you have installed **virtualbox** (^6.1.6) and **vagrant** (=2.2.7) then you can do the following:

1. Open terminal on project folder
2. Run `vagrant up && vagrant ssh` (then you will be inside the vm)
3. Run `cd /vagrant` (project folder)
4. Initialize Project with `./init.sh`
5. Add email information on the global.override.env file
6. Run `docker-compose up -d` (takes about 4min)
7. Check containers are running without any problems `docker container ls`
8. Go to `https://bitwarden.local`

## Tips

If you have an online domain try out the letsencrypt service. It also renews automatically without needing to restart
nginx container manualy.

## Notes

This solution, can be further simplified. The following
* I think global.ovveride.env file, could be simpler.
* As for now, this version supports only linux, but can be easily made to support also windows os
* I've uploaded dhparam.pem as it takes long time to create (for simplicity reasons)
* The 

There are many changes, on this version. Some examples are:

- database environment variables are on docker-compose. The user has no benefit of modifying them and therefore are removed from `mssql.global.env`.
- LOCAL_UID, LOCAL_GUID are put in docker-compose file. Not something a user will usually deal with

Proxy service is build localy, so that the user can always change them on docker-compose file without needing install script.
By using local domain names, the services can communicate directly through their deticated network (reducing proxy overhead).

## Questions

1. Can I generate myself the identity.pfx, or it should always be copied?
2. Which service communicate with which?
3. Which services can I cut out access on the internet? (compose-file: netorks > internal: true)
4. Which services communicate with proxy? Note that with the aliases under `bitwarden-net` I can redirect the messages with an alias localy without needing proxy service

## Future imporvements

1. Support for all platforms
2. Single command install (with minimal questions)
3. Identity.pfx chould be contained inside identity container when downloading if It can't be created locally
4. app-id.json chould be created inside web container by an Environment variable ex: `BW_URL`
5. etc. ...

