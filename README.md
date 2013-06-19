# Bowron

Sequencing, rendering, synthesis and processing algorithms for [Bowron](https://soundcloud.com/credit/bowron).

This is a little over half of the code used to realize a piece for Tuba and computer that was produced in collaboration with tubaist [Jon Hansen](http://www.jonhansenmusic.com/). It is provided as-is, with few comments and without the score files needed for actually reproducing the piece. The 'Sample Score.scd' demonstrates how to consruct a score file and execute it to render sound.

Not well organized, I'm afraid. There will be a major rewrite of the whole system for our next piece. PS is the heart of the whole thing, SM defines the functions for populating the CtkScore object, the TB files define time signature and tempo schemas for different sections of the piece.

Everything else is prodivded for the curious: synthesis definitions and all of the functions for turning the scores into sound.

------

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
