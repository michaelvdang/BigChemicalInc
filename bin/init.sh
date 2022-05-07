#!/bin/bash

mkdir -p var/
sqlite3 var/BigChemicalInc.db < share/BigChemicalInc.sql
sqlite3 var/BigChemicalInc.db < share/create_views.sql