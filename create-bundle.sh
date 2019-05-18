#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#get component name
if [ $1 ]; then
  COMPONENTNAME=$1
else
  echo -e "Enter component name: \c"
  read COMPONENTNAME
fi

COMPONENTPATH="./$COMPONENTNAME"

echo
# fail if folder already exists
if [ -d $COMPONENTPATH ]; then
  echo "Folder with name '$COMPONENTNAME' already exists, please choose a different name"
  exit
fi

# create root-level folders and files
mkdir $COMPONENTNAME
cd $COMPONENTNAME
mkdir src
touch .babelrc
touch .gitignore
touch .npmignore
touch README.md
touch webpack.config.js


# create helper .js file (will be deleted later)
touch add-package-scripts.js

read -r -d '' ADDSCRIPTS <<EOF
const fs = require('fs');
const package = require('./package.json');

const scriptsToAdd = process.argv.slice(2);

scriptsToAdd.forEach(scriptToAdd => {
  const [scriptName, script] = scriptToAdd.split('=');
  
  if (package.scripts[scriptName]) {
    console.log(scriptName, 'script already exists, skipping...');
    return;
  }
  
  package.scripts[scriptName]= script;
});

fs.writeFileSync('./package.json', JSON.stringify(package, null, "\t"));
EOF
echo "$ADDSCRIPTS" >> add-package-scripts.js


npm init -y
npm i --save react classnames prop-types
npm i -D tar @babel/core @babel/plugin-proposal-class-properties @babel/preset-env @babel/preset-react babel-cli babel-loader css-loader mini-css-extract-plugin node-sass style-loader sass-loader webpack webpack-cli

node ./add-package-scripts.js start="webpack --watch" build="webpack"


read -r -d '' BABELRC <<EOF
{
  "presets": [
    "@babel/preset-env",
    "@babel/preset-react"
  ],
  "plugins": [
    "@babel/plugin-proposal-class-properties"
  ]
}
EOF
echo "$BABELRC" >> .babelrc


read -r -d '' NPMIGNORE <<EOF
src
.babelrc
webpack.config.js
EOF
echo "$NPMIGNORE" >> .npmignore


echo "node_modules" >> .gitignore


read -r -d '' README <<EOF
# $COMPONENTNAME

\`TODO\` write readme


# Usage

\`npm install $COMPONENTNAME\`

## Development
* clone repo && \`npm install\`
* Development server \`npm start\`
* Build \`npm run build\`
EOF
echo "$README" >> README.md



read -r -d '' WEBPACKCONFIG <<EOF
const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  entry: './src/index.js',
  output: {
    path : path.resolve('dist'),
    filename: 'index.js',
    libraryTarget: 'commonjs2'
  },
  module: {
    rules : [
      {
        test : /\.js?$/,
        include: path.resolve(__dirname, 'src'),
        exclude : /(node_modules|bower_components|dist)/,
        use : {
          loader : 'babel-loader'
        }
      },
      {
        test: /\.scss$/,
        use : [
          "style-loader",
          "css-loader",
          "sass-loader"
        ]
      }
    ]
  },
  plugins:[
    new MiniCssExtractPlugin({
      filename: "[name].css",
      chunkFilename: "[id].css"
    })
  ],
  externals: {
    'react': 'commonjs react'
  }
}
EOF
echo "$WEBPACKCONFIG" >> webpack.config.js



cd src
touch index.js
touch index.scss


read -r -d '' INDEXJS <<EOF
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import classnames from 'classnames';

import "./index.scss";

class MyComponent extends Component {
  render() {
    return (
      <div>My Component</div>
    )
  }
}

MyComponent.propTypes = {};

MyComponent.defaultProps = {};

export default MyComponent;
EOF
echo "$INDEXJS" >> index.js

cd ..

rm add-package-scripts.js

cd ..

echo "${bold}React Component successfully created!"
echo "${normal}To publish: ${bold}cd $COMPONENTNAME${normal}, then ${bold}npm run build${normal}, then login with ${bold}npm login${normal} and then publish with ${bold}npm publish.${normal}"

exit