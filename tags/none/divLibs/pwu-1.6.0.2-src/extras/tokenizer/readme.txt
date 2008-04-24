
 <rant>
  This parser parses pascal code without being an FPDOC tool itself, and without
  being a synedit component. It's a modular pascal tokenizer you can use for
  analyzing pascal code.. separate from any other code. What good is the parser
  in FpDoc and PasDoc if one can't use it separately from the doc tool? What if
  I don't need the Doc tool and I just want to tokenize some code? What if I
  don't need synedit and I just   want to tokenize some code? A parser should be
  separated from other code logic that runs the tool or control, IMO. Unless
  speed is a serious issue, such as in the FP compiler's case may be true - I
  really   don't understand why synedit and fpdoc and pasdoc tools have not
  modularized their parsers into separate tools/units, rather than embedding the
  parser into their code logic).

  THE PARSER SHOULD BE A SEPARATE DOWNLOADABLE TOOL, NOT EMBEDDED INTO THE CODE
  LOGIC THAT RUNS ONE SPECIFIC TOOL OR COMPONENT.  ANYONE SHOULD BE ABLE TO
  DOWNLOAD THE FPDOC PARSER SEPARATELY FROM THE FPDOC TOOL, OTHERWISE THE PARSER
  IS NEVER A REUSABLE  TOOL ITSELF! WORTHLESS NIGHTMARE TRYING TO EXTRACT THE
  PARSING CODE FROM THE FPDOC TOOL!  WORTHLESS NIGHTMARE TRYING TO INHERIT THE
  FPDOC TOOL AND MAKE MY OWN TOOL BASED ON THE FPDOC TOOL.

  I don't understand why a parser must be literally embedded into the program.
  That's not code "reuse". If you can't reuse the parser, it just doesn't make
  sense. (in fp-compiler's case, the parser is optimized for speed, probably
  couldn't separate the parser without sacrificing speed - but in
  FPDOC/PASDOC/SYNEDIT's case? Noone cares if FPDOC takes 2 seconds longer.)

  Now, it could be that I'm missing some factor here - but I really think a
  parser should be modularized away into it's own reusable unit/tool, and should
  not be embedded into the actual tool that uses the parser!
 </rant>
