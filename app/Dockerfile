FROM node:16

ENV CI=true

WORKDIR /app

COPY package.json ./

RUN npm install

COPY ./ ./

RUN chmod 775 pipeline_scripts/eMAGMA.sh

#install R and packages
RUN apt update
RUN apt-get install -y r-base
RUN apt-get install -y -qq r-cran-qqman

#remove windows line endings
RUN apt-get install dos2unix
RUN dos2unix pipeline_scripts/eMAGMA.sh

RUN npm run build

CMD [ "npm", "run", "start:prod" ]
