# Bowron

Sequencing, rendering, synthesis and processing algorithms for [Bowron](https://soundcloud.com/credit/bowron).

This is a little over half of the code used to realize a piece for Tuba and computer that was produced in collaboration with tubaist [Jon Hansen](http://www.jonhansenmusic.com/). It is provided as-is, with few comments and without the score files needed for actually reproducing the piece itself. The 'Sample Score.scd' demonstrates how to consruct a score file and execute it to render sound. proto_gestures, proto_gv, and protos all contain some more non-trivial examples of populating a score file.

There will be a major rewrite of the whole system for our next piece, that version will be updated here.

## What's what

SD contains the all-powerful synthesis definitions.

PS contains the main functions of the system.

SM defines the functions for populating the CtkScore object

TB files define time signature and tempo schemas for different sections of the piece (I included several of these to demonstrate a range of possiblities).

test_dissolver contains a pair of synthesis definitions extracted for easy testing.

mixer is used to run the ~mix function that will render partial tracks into full-length stem tracks.

------

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
