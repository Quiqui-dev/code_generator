[[_TOC_]]

# Introduction

This project is one of a multi-purpose quality-of-life code generator using XSL for transforming and XML files for data modelling, as well as XSLT through the Saxon jar package.

# Requirements

[Saxon](https://sourceforge.net/projects/saxon/) 

# Instructions

## Generating SQL 

For generating the SQL DDL for any XML files run the following in a terminal from the root of this repo (i.e. Generator/)

```
source ./bin/genDDL.sh <absPath/to/xmlDirToTransform> <absPath/to/xslDir> <absPath/to/outputDir>
```

This will then perform the transform and produce the SQL file to deploy the tables in the output directory specified.

## Generating Python Classes

For generating the Python `Access Classes` for any XML files run the following command in the terminal from the root of the repo

```
source ./bin/genAC.sh <absPath/to/xmlDirToTransform> <absPath/to/xslDir> <absPath/to/outputDir>
```

This will then produce one read and write access class for each xml file transformed