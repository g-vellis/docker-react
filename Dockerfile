# production-Dockerfile version

# Build Phase (our temporary Container or one set of layers). 
# we tag this phase with a name (i.e. builder) by using the 'as' keyword.
# => from the FROM command and everything underneath it, it is all going
# to be referred to as 'the builder face'.
# The sole purpose of this phase (i.e. 'builder'), is 
#   - to install dependencies, and 
#   - build our application. 
FROM node:alpine as builder

WORKDIR '/app'

# copy over my package.json file to that /app/ directory. 
COPY package.json .

# install the dependencies specified in the copied package.json
RUN npm install

# I'll copy over all of my source code.
# Notice, now that we are doing this build phase 
# we do not have any concern over changing
# our source code. So, we do not have to make use 
# of that entire volume system anymore anymore. 
#
# That volume system that we used in docker-compose 
# was only required because we wanted 
# to develop our application and have our changes 
# immediately show up inside the container.
#
# In a production environment that is not a concern anymore. 
# Because, we are not changing our code at all. 
#
# So, we can just do a straight copy of all of our source code 
# directly into the container. 
COPY . .

# The result of the following command will be a, so called, 'build' folder.
# comprising the index.html and the js file with all the src code and
# the dependencies encapsulated in it.
# NOTE: the 'build' foder willbe created in the working directory.
#
# So, the folder that you and I really care about,
# i.e. the folder with all of our production assets that
# we want to serve up to the outside world, 
# the path to that inside the Container will be:
# /app/build
# that is going to have all the stuff we care about.
# /app/build <-- all the stuff
# So that is the folder that we are going to eventually 
# want to somehow copy over during our run phase.
RUN npm run build


# The RUN Phase
FROM  nginx

# we just copy over just the bare minimum, just the stuff we care about, from
# the previous step. 
#  So, when we do this copy step below, we are essentially dumping everything else 
# that was created while the previous set of configuration was executed. 
# So, 
#   1. we are not pulling over anything from the node:alpine Image. 
#   2. We're not pulling over any of the results of the npm install.
#   3. We're not copying over any of our source code.
# All we are getting is the result of that '/app/build' directory. 

# Copy over that 'build' folder, into this new nginx Container thing 
# that we're putting together.
# COPY sth FROM a different phase => we use --from 
# i.e. I want to copy over sth from that other phase that we we're just working on.
#                    the folder to copy   the nginx-specific folder to place comntent into to be auto served. 
COPY --from=builder /app/build /usr/share/nginx/html

# It turns out that the default command of the nginx Container or thenginx Image 
# is going to start up nginx for us.
# So, we don't have to actually specifically run anything to startup nginx
#  when we start up the nginx Container.
# It is going to take care of the command for us automatically.
