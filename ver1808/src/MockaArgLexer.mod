(*!m2pim+mocka*)

(* ------------------------------------------------------------------------ *
 * MOCKA Modula-2 Compiler System, Version 1807                             *
 *                                                                          *
 * Copyright (C) 1988-2000 by                                               *
 *  GMD Gesellschaft fuer Mathematik und Datenverarbeitung,                 *
 *  Ehemalige GMD Forschungsstelle an der Uni Karlsruhe;                    *
 *  [EN] German National Research Center for Computer Science,              *
 *  Former GMD Research Lab at the University of Karlsruhe.                 *
 *                                                                          *
 * Copyright (C) 2001-2018 by                                               *
 *  Fraunhofer-Gesellschaft zur Foerderung der angewandten Forschung;       *
 *  [EN] Fraunhofer Society for the Advancement of Applied Research.        *
 *                                                                          *
 * File 'MockaArgLexer.mod' Copyright (C) 2018, Benjamin Kowarsch           *
 * ------------------------------------------------------------------------ *)

IMPLEMMENTATION MODULE MockaArgLexer;

(* Command Line Argument Lexer *)


IMPORT MockaArgReader;


(* ------------------------------------------------------------------------
 * Argument strings
 * ------------------------------------------------------------------------ *)

CONST
  ArgStrHelp = "--help";
  ArgStrVersion = "--version";
  ArgStrCopyright = "--copyright";

  ArgStrOctalLiterals = "--octal-literals";
  ArgStrNoOctalLiterals = "--no-octal-literals";
  ArgStrSynonymSymbols = "--synonym-symbols";
  ArgStrNoSynonymSymbols = "--no-synonym-symbols";

  ArgStrIndexChecks = "--index-checks";
  ArgStrNoIndexChecks = "--no-index-checks";
  ArgStrRangeChecks = "--range-checks";
  ArgStrNoRangeChecks = "--no-range-checks";

  ArgStrElf = "--elf";
  ArgStrMachO = "--mach-o";
  ArgStrKeepAsm = "--keep-asm";
  ArgStrPurgeAsm = "--purge-asm";
  ArgStrBuild = "--build";
  ArgStrNoBuild = "--no-build";
  ArgStrStatic = "--static";
  ArgStrNoStatic = "--no-static";

  ArgStrDebug = "--debug";
  ArgStrNoDebug = "--no-debug";
  ArgStrVerbose = "--verbose";
  ArgStrShowSettings = "--show-settings";

  ArgStrLibPath = "--lib-path";
  ArgStrWorkDir = "--work-dir";


(* ------------------------------------------------------------------------
 * Character constants
 * ------------------------------------------------------------------------ *)

  NUL = CHR(0);
  TAB = CHR(9);
  SPACE = CHR(32);
  NEWLINE = CHR(10);


(* ------------------------------------------------------------------------
 * Lexeme of last consumed argument
 * ------------------------------------------------------------------------ *)

VAR lastLexeme : ARRAY [0..MaxArgStrLen] OF CHAR;


(* ------------------------------------------------------------------------
 * public function nextToken()
 * ------------------------------------------------------------------------
 * Reads and consumes the next command line argument and returns its token.
 * ------------------------------------------------------------------------ *)

PROCEDURE nextToken : Token;

VAR
  next : CHAR;
  token : Token;

BEGIN
  next := lookaheadChar(args);

  (* skip whitespace, tab and newline *)
  WHILE NOT eof(args) AND
    ((next = SPACE) OR (next = TAB) OR (next = NEWLINE)) DO
    next := consumeChar(args)
  END; (* WHILE *)

  IF eof(args) THEN
    token := EndOfInput;
    lastLexeme := NUL;

  ELSE
    CASE next OF
    (* option *)
    | "-" :
      GetOption(next, token, lastLexeme)

    (* filename *)
    | "A" .. "Z",
      "a" .. "z" :
      GetFilename(next, token, lastLexeme)

    (* relative path *)
    | "." :
      GetRelativePath(next, token, lastLexeme)

    (* absolute path *)
    | '/' :
      GetAbsolutePath(next, token, lastLexeme)

    (* home directory path *)
    | '~' :
      GetHomeDirPath(next, token, lastLexeme)

    ELSE (* invalid argument *)
      token := Invalid;
      lastLexeme := NUL;
    END (* CASE *)
  END (* IF *)

  RETURN token
END nextToken;


(* ------------------------------------------------------------------------
 * public procedure GetLastArg(lastArg)
 * ------------------------------------------------------------------------
 * Passes the argument string of the last consumed argument in 'lastArg'.
 * If the end of input token has been returned by a prior call to function
 * nextToken(), or if the capacity of 'lastArg' is less than MaxArgStrLen,
 * an empty string is passed instead.
 * ------------------------------------------------------------------------ *)

 PROCEDURE GetLastArg ( VAR lastArg : ARRAY OF CHAR );

BEGIN
  (* assert that the capacity of lastArg is at least MaxArgStrLen *)
  IF HIGH(lastArg) < MaxArgStrLen THEN
    lastArg := NUL;
    RETURN
  END; (* IF *)

  lastArg := lastLexeme
END GetLastArg;


(* ------------------------------------------------------------------------
 * public procedure GetArgStrForToken(argStr, token)
 * ------------------------------------------------------------------------
 * Passes the argument string for 'token' in 'argStr'.  If any of Invalid,
 * SourceFile or EndOfInput is passed in for 'token',  or if the capacity
 * of 'argStr' is less than MaxArgStrLen, an empty string is passed instead.
 * ------------------------------------------------------------------------ *)

PROCEDURE GetArgStrForToken ( VAR argStr : ARRAY OF CHAR; token : Token );

BEGIN
  (* assert that the capacity of argStr is at least MaxArgStrLen *)
  IF HIGH(argStr) < MaxArgStrLen THEN
    argStr := NUL;
    RETURN
  END; (* IF *)

  CASE token OF
  | Help :
    argStr := ArgStrHelp

  | Version :
    argStr := ArgStrVersion

  | Copyright :
    argStr := ArgStrCopyright

  | OctalLiterals :
    argStr := ArgStrOctalLiterals

  | NoOctalLiterals :
    argStr := ArgStrNoOctalLiterals

  | SynonymSymbols :
    argStr := ArgStrSynonymSymbols

  | NoSynonymSymbols :
    argStr := ArgStrNoSynonymSymbols

  | IndexChecks :
    argStr := ArgStrIndexChecks

  | NoIndexChecks :
    argStr := ArgStrNoIndexChecks

  | RangeChecks :
    argStr := ArgStrRangeChecks

  | NoRangeChecks :
    argStr := ArgStrNoRangeChecks

  | Elf :
    argStr := ArgStrElf

  | MachO :
    argStr := ArgStrMachO

  | KeepAsm :
    argStr := ArgStrKeepAsm

  | PurgeAsm :
    argStr := ArgStrPurgeAsm

  | Build :
    argStr := ArgStrBuild

  | NoBuild :
    argStr := ArgStrNoBuild

  | Static :
    argStr := ArgStrStatic

  | NoStatic :
    argStr := ArgStrNoStatic

  | Debug :
    argStr := ArgStrDebug

  | NoDebug :
    argStr := ArgStrNoDebug

  | Verbose :
    argStr := ArgStrVerbose

  | ShowSettings :
    argStr := ArgStrShowSettings

  | LibPath :
    argStr := ArgStrLibPath

  | WorkDir :
    argStr := ArgStrWorkDir

  ELSE (* any other token yields empty string *)
    argStr := NUL
  END (* CASE *)
END GetArgStrForToken;


(* ------------------------------------------------------------------------
 * public function isInfoRequest(token)
 * ------------------------------------------------------------------------
 * Returns TRUE if 'token' represents an information request.
 * ------------------------------------------------------------------------ *)

PROCEDURE isInfoRequest ( token : Token ) : BOOLEAN;
BEGIN
  RETURN (token >= Help) AND (token <= Copyright)
END isInfoRequest;


(* ------------------------------------------------------------------------
 * public function isCompilationRequest(token)
 * ------------------------------------------------------------------------
 * Returns TRUE if 'token' represents a compilation request.
 * ------------------------------------------------------------------------ *)

PROCEDURE isCompilationRequest ( token : Token ) : BOOLEAN;
BEGIN
  RETURN (token >= OctalLiterals) AND (token <= SourceFile)
END isCompilationRequest;


(* ------------------------------------------------------------------------
 * public function isSyntaxOption(token)
 * ------------------------------------------------------------------------
 * Returns TRUE if 'token' represents a syntax option.
 * ------------------------------------------------------------------------ *)

PROCEDURE isSyntaxOption ( token : Token ) : BOOLEAN;
BEGIN
  RETURN (token >= OctalLiterals) AND (token <= NoSynonymSymbols)
END isSyntaxOption;


(* ------------------------------------------------------------------------
 * public function isSafetyOption(token)
 * ------------------------------------------------------------------------
 * Returns TRUE if 'token' represents a safety option.
 * ------------------------------------------------------------------------ *)

PROCEDURE isSafetyOption ( token : Token ) : BOOLEAN;
BEGIN
  RETURN (token >= IndexChecks) AND (token <= NoRangeChecks)
END isSafetyOption;


(* ------------------------------------------------------------------------
 * public function isProductOption(token)
 * ------------------------------------------------------------------------
 * Returns TRUE if 'token' represents a product option.
 * ------------------------------------------------------------------------ *)

PROCEDURE isProductOption ( token : Token ) : BOOLEAN;
BEGIN
  RETURN (token >= Elf) AND (token <= NoStatic)
END isProductOption;


(* ------------------------------------------------------------------------
 * public function isDiagOption(token)
 * ------------------------------------------------------------------------
 * Returns TRUE if 'token' represents a diagnostic option.
 * ------------------------------------------------------------------------ *)

PROCEDURE isDiagOption ( token : Token ) : BOOLEAN;
BEGIN
  RETURN (token >= Debug) AND (token <= ShowSettings)
END isDiagOption;


(* ------------------------------------------------------------------------
 * public function isPathOption(token)
 * ------------------------------------------------------------------------
 * Returns TRUE if 'token' represents a path option.
 * ------------------------------------------------------------------------ *)

PROCEDURE isPathOption ( token : Token ) : BOOLEAN;
BEGIN
  RETURN (token >= LibPath) AND (token <= WorkDir)
END isPathOption;


(* ------------------------------------------------------------------------
 * private procedure GetOption(next, token, lexeme)
 * ------------------------------------------------------------------------
 * Parses an option from the argument input and passes back its token and
 * lexeme. Passes the new lookahead character back in 'next'.
 * ------------------------------------------------------------------------ *)

PROCEDURE GetOption
  ( VAR next : CHAR; VAR token : Token; VAR lexeme : ARRAY OF CHAR );

VAR
  index : CARDINAL;

BEGIN
  (* copy lookahead to lexeme *)
  lexeme[0] := next;
  index := 1;

  (* consume first prefix character *)
  next := consumeChar(args);

  (* consume second prefix character *)
  IF next = "-" THEN
    (* copy char to lexeme *)
    lexeme[1] := next;
    index := 2;

    (* consume *)
    next := consumeChar(args)
  END; (* IF *)

  (* consume all characters until whitespace or end of input is reached *)
  WHILE NOT eof(args) AND (next # SPACE) DO
    (* copy char to lexeme *)
    lexeme[index] := next;
    index := index + 1;

    (* consume *)
    next := consumeChar(args)
  END; (* WHILE *)

  (* terminate lexeme *)
  lexeme[index] := NUL;

  (* pass token for lexeme *)
  token := optionTokenForLexeme(lexeme)
END GetOption;


(* ------------------------------------------------------------------------
 * private function optionTokenForLexeme(lexeme)
 * ------------------------------------------------------------------------
 * Returns the option token for 'lexeme' or Invalid if 'lexeme' does not
 * match any valid option.
 * ------------------------------------------------------------------------ *)

PROCEDURE optionTokenForLexeme ( VAR lexeme : ARRAY OF CHAR ) : Token;

VAR
  len : CARDINAL;

BEGIN
  len := strLen(lexeme);

  CASE len OF

  (* short options *)

  | 2 : (* -A, -B, -D, -I, -L, -R, -S, -W, -a, -b, -d, -h, -i, -r, -s, -v *)
    CASE lexeme[1] OF
    | "A" : (* -A *) RETURN KeepAsm
    | "B" : (* -B *) RETURN Build
    | "D" : (* -D *) RETURN Debug
    | "I" : (* -I *) RETURN IndexChecks
    | "L" : (* -L *) RETURN LibPath
    | "R" : (* -R *) RETURN RangeChecks
    | "S" : (* -S *) RETURN Static
    | "W" : (* -W *) RETURN WorkDir
    | "a" : (* -a *) RETURN PurgeAsm
    | "b" : (* -b *) RETURN NoBuild
    | "d" : (* -d *) RETURN NoDebug
    | "h" : (* -h *) RETURN Help
    | "i" : (* -i *) RETURN NoIndexChecks
    | "r" : (* -r *) RETURN NoRangeChecks
    | "s" : (* -s *) RETURN NoStatic
    | "v" : (* -v *) RETURN Verbose
    END (* CASE *)

  (* long options *)

  | 5 : (* --elf *)
    IF strMatches(lexeme, ArgStrElf) THEN
      RETURN Elf
    END (* IF *)

  | 6 : (* --help *)
    IF strMatches(lexeme, ArgStrHelp) THEN
      RETURN Help
    END (* IF *)

  | 7 : (* --build, --debug *)
    CASE lexeme[2] OF
    | "b" : (* --build *)
      IF strMatches(lexeme, ArgStrBuild) THEN
        RETURN Build
      END (* IF *)
    | "d" : (* --debug *)
      IF strMatches(lexeme, ArgStrDebug) THEN
        RETURN Debug
      END (* IF *)
    END (* CASE *)

  | 8 : (* --mach-o, --static *)
    CASE lexeme[2] OF
    | "m" : (* --mach-o *)
      IF strMatches(lexeme, ArgStrMachO) THEN
        RETURN MachO
      END (* IF *)
    | "s" : (* --static *)
      IF strMatches(lexeme, ArgStrStatic) THEN
        RETURN Static
      END (* IF *)
    END (* CASE *)

  | 9 : (* --verbose, --version *)
    CASE lexeme[5] OF
    | "b" : (* --verbose *)
      IF strMatches(lexeme, ArgStrVerbose) THEN
        RETURN Verbose
      END (* IF *)
    | "s" : (* --version *)
      IF strMatches(lexeme, ArgStrVersion) THEN
        RETURN Version
      END (* IF *)
    END (* CASE *)

  | 10 : (* --no-build, --no-debug, --lib-path, --keep-asm, --work-dir *)
    CASE lexeme[9] OF
    | "d" : (* --no-build *)
      IF strMatches(lexeme, ArgStrNoBuild) THEN
        RETURN NoBuild
      END (* IF *)
    | "g" : (* --no-debug *)
      IF strMatches(lexeme, ArgStrNoDebug) THEN
        RETURN NoDebug
      END (* IF *)
    | "h" : (* --lib-path *)
      IF strMatches(lexeme, ArgStrLibPath) THEN
        RETURN LibPath
      END (* IF *)
    | "m" : (* --keep-asm *)
      IF strMatches(lexeme, ArgStrKeepAsm) THEN
        RETURN KeepAsm
      END (* IF *)
    | "r" : (* --work-dir *)
      IF strMatches(lexeme, ArgStrWorkDir) THEN
        RETURN WorkDir
      END (* IF *)
    END (* CASE *)

  | 11 : (* --copyright, --no-static, --purge-asm *)
    CASE lexeme[2] OF
    | "c" : (* --copyright *)
      IF strMatches(lexeme, ArgStrCopyright) THEN
        RETURN Copyright
      END (* IF *)
    | "n" : (* --no-static *)
      IF strMatches(lexeme, ArgStrNoStatic) THEN
        RETURN NoStatic
      END (* IF *)
    | "p" : (* --purge-asm *)
      IF strMatches(lexeme, ArgStrPurgeAsm) THEN
        RETURN PurgeAsm
      END (* IF *)
    END (* CASE *)

  | 14 : (* --index-checks, --range-checks *)
    CASE lexeme[2] OF
    | "i" : (* --index-checks *)
      IF strMatches(lexeme, ArgStrIndexChecks) THEN
        RETURN IndexChecks
      END (* IF *)
    | "r" : (* --range-checks *)
      IF strMatches(lexeme, ArgStrRangeChecks) THEN
        RETURN RangeChecks
      END (* IF *)
    END (* CASE *)

  | 15 : (* --show-settings *)
    IF strMatches(lexeme, ArgStrShowSettings) THEN
      RETURN ShowSettings
    END (* IF *)

  | 16 : (* --octal-literals *)
    IF strMatches(lexeme, ArgStrOctalLiterals) THEN
      RETURN OctalLiterals
    END (* IF *)

  | 17 : (* --no-index-checks, --synonym-symbols, --no-range-checks *)
    CASE lexeme[5] OF
    | "i" : (* --no-index-checks *)
      IF strMatches(lexeme, ArgStrNoIndexChecks) THEN
        RETURN NoIndexChecks
      END (* IF *)
    | "o" : (* --synonym-symbols *)
      IF strMatches(lexeme, ArgStrSynonymSymbols) THEN
        RETURN SynonymSymbols
      END (* IF *)
    | "r" : (* --no-range-checks *)
      IF strMatches(lexeme, ArgStrNoRangeChecks) THEN
        RETURN NoRangeChecks
      END (* IF *)
    END (* CASE *)

  | 19 : (* --no-octal-literals *)
    IF strMatches(lexeme, ArgStrNoOctalLiterals) THEN
      RETURN NoOctalLiterals
    END (* IF *)

  | 20 : (* --no-synonym-symbols *)
    IF strMatches(lexeme, ArgStrNoSynonymSymbols) THEN
      RETURN NoSynonymSymbols
    END (* IF *)

  ELSE (* invalid option *)
    RETURN Invalid
  END (* CASE *)
END tokenForLexeme;


(* ------------------------------------------------------------------------
 * private function strLen(str)
 * ------------------------------------------------------------------------
 * Returns the length of 'str'.
 * ------------------------------------------------------------------------ *)

PROCEDURE strLen ( (*CONST*) VAR str : ARRAY OF CHAR ) : CARDINAL;

VAR
  index : CARDINAL;

BEGIN
  index := 0;

  (* search for ASCII NUL *)
  REPEAT
    IF str[index] = NUL THEN
      EXIT
    ELSE
      index := index + 1
    END (* IF *)
  UNTIL index > HIGH(str);

  (* index contains length *)
  RETURN index
END strLen;


(* ------------------------------------------------------------------------
 * private function strMatches(s1, s2)
 * ------------------------------------------------------------------------
 * Returns TRUE if 's1' matches 's2', otherwise FALSE.
 * ------------------------------------------------------------------------ *)

PROCEDURE strMatches ( (*CONST*) VAR s1, s2 : ARRAY OF CHAR ) : BOOLEAN;

VAR
  ch1, ch2 : CHAR;
  index : CARDINAL;

BEGIN
  index := 0;

  (* search for mismatching character or ASCII NUL *)
  REPEAT
    ch1 := s1[index]; ch2 := s2[index];
    IF ch1 # ch2 THEN
      (* mismatch *)
      RETURN FALSE

    ELSIF ch1 = NUL THEN
      (* end of string reached, all characters matched *)
      RETURN TRUE

    ELSE (* end of string not reached, continue *)
      index := index + 1
    END (* IF *)
  UNTIL (index > HIGH(s1)) OR (index > HIGH(s2));

  (* check for possibly unterminated string (PIM3) *)
  IF HIGH(s1) = HIGH(s2) THEN
    (* all characters matched *)
    RETURN TRUE
  ELSE
    (* length mismatch *)
    RETURN FALSE
  END (* IF *)
END strMatches;


(* ------------------------------------------------------------------------
 * private procedure GetFilename(next, token, lexeme)
 * ------------------------------------------------------------------------
 * Parses a filename from the argument input and passes back its token and
 * lexeme. Passes the new lookahead character back in 'next'.
 * ------------------------------------------------------------------------ *)

PROCEDURE GetFilename
  ( VAR next : CHAR; VAR token : Token; VAR lexeme : ARRAY OF CHAR );

BEGIN
  (* TO DO *)
END GetFilename;


(* ------------------------------------------------------------------------
 * private procedure GetRelativePath(next, token, lexeme)
 * ------------------------------------------------------------------------
 * Parses a relative path from the argument input and passes back its token
 * and lexeme. Passes the new lookahead character back in 'next'.
 * ------------------------------------------------------------------------ *)

PROCEDURE GetRelativePath
  ( VAR next : CHAR; VAR token : Token; VAR lexeme : ARRAY OF CHAR );

BEGIN
  (* TO DO *)
END GetRelativePath;


(* ------------------------------------------------------------------------
 * private procedure GetAbsolutePath(next, token, lexeme)
 * ------------------------------------------------------------------------
 * Parses an absolute path from the argument input and passes back its
 * token and lexeme. Passes the new lookahead character back in 'next'.
 * ------------------------------------------------------------------------ *)

PROCEDURE GetAbsolutePath
  ( VAR next : CHAR; VAR token : Token; VAR lexeme : ARRAY OF CHAR );

BEGIN
  (* TO DO *)
END GetAbsolutePath;


(* ------------------------------------------------------------------------
 * private procedure GetHomeDirPath(next, token, lexeme)
 * ------------------------------------------------------------------------
 * Parses a home directory path from the argument input and passes back its
 * token and lexeme. Passes the new lookahead character back in 'next'.
 * ------------------------------------------------------------------------ *)

PROCEDURE GetHomeDirPath
  ( VAR next : CHAR; VAR token : Token; VAR lexeme : ARRAY OF CHAR );

BEGIN
  (* TO DO *)
END GetHomeDirPath;


BEGIN (* MockaArgLexer *)
  lastLexeme := NUL
END MockaArgLexer.
