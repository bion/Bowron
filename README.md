# Bowron
======
Sequencing, rendering, synthesis and processing algorithms for Bowron.

This is a little over half of the code used to realize [Bowron](https://soundcloud.com/credit/bowron), a piece for Tuba and computer produced in collaboration with tubaist [Jon Hansen](http://www.jonhansenmusic.com/). It is provided as-is, with few comments and without the score files needed for actually reproducing the piece. The 'Sample Score.scd' demonstrates how to consruct a score file and execute it to render sound.

Not well organized, I'm afraid. There will be a major rewrite of the whole system for our next piece. PS is the heart of the whole thing, SM defines the functions for populating the CtkScore object, the TB files define time signature and tempo schemas for different sections of the piece.

Everything else is prodivded for the curious: synthesis definitions and all of the functions for turning the scores into sound.
