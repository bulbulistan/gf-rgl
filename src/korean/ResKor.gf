resource ResKor = ParamKor ** open Prelude, Predef, ParamKor in {

--------------------------------------------------------------------------------
-- Nouns
oper

  Noun : Type = {
    s : NForm => Str ;
    p : Phono
    } ;
  Noun2 : Type = Noun ; -- TODO eventually more parameters?
  Noun3 : Type = Noun ;

  CNoun : Type = Noun ** {
    } ;

  PNoun : Type = Noun ;

  mkNoun : Str -> Noun = \str -> {
    s = \\cas => str + allomorph cas str ;
    p = if_then_else Phono (vowFinal str) Vowel Consonant ;
    } ;

  useN : Noun -> CNoun = \n -> n ;

---------------------------------------------
-- NP

  -- BaseNP : Type = {
  --   a : Agreement ;
  --   isPron : Bool ;
  --   empty : Str ; -- standard trick for pro-drop
  --   } ;
  --
  -- emptyNP : NounPhrase = {
  --   s = \\_ => [] ;
  --   a = Sg3 Masc ;
  --   isPron = False ;
  --   empty = [] ;
  --   } ;
  --
  -- indeclNP : Str -> NounPhrase = \s -> emptyNP ** {s = \\c => s} ;

  --NounPhrase : Type = BaseNP ** {s : NForm => Str} ;
  NounPhrase = Noun ;

--------------------------------------------------------------------------------
-- Pronouns

  Pronoun : Type = NounPhrase ** {
    -- poss : { -- for PossPron : Pron -> Quant
    --   } ;
    sp : NForm => Str ;
    } ;


--------------------------------------------------------------------------------
-- Det, Quant, Card, Ord

  BaseQuant : Type = {
    s : Str ;
    isPoss : Bool ;
    p : Phono
    } ;

  Determiner : Type = BaseQuant ** {
    sp : NForm => Str ;
    n : Number ;
--    numtype : NumType ; -- number as in "5" or "Sg/Pl", often makes a difference in lots of things
    } ;

  Quant : Type = BaseQuant ** {
    sp : NForm => Str ;
    } ;

  Num : Type = {
    s : DForm => Str ; -- independent or attribute
    n : Number
    } ;

  baseNum : Num = {
    s = \\_ => [] ;
    n = Sg ;
    numtype = NoNum
    } ;

  Numeral : Type = Num ** {
    ord : Str
    } ;

  baseQuant : BaseQuant = {
    s = [] ;
    isPoss = False ;
    p = Vowel ;
  } ;

  mkQuant : (s,sp : Str) -> Quant = \s,sp -> baseQuant ** {
    s = s ;
    sp = (mkNoun sp).s ;
    p = (mkNoun sp).p ;
  } ;

  plural : NForm => Str = table {
    Bare => "들" ;
    nf => "들" + allomorph nf "들"
  } ;
--------------------------------------------------------------------------------
-- Postpositions

  Postposition : Type = SS ;

  mkPrep : Str -> Postposition = \str -> ss str ;

  emptyPP : Postposition = mkPrep [] ;
  datPP : Postposition = mkPrep "에게" ;

--------------------------------------------------------------------------------
-- Adjectives

  Adjective : Type = {s : AForm => Str} ;
  Adjective2 : Type = Adjective ;

  mkAdj : Str -> Adjective = \plain ->
   let stem = init plain ;
       verb = mkVerb plain Stative ;
   in {
     s = table { AAttr    => add_N stem ;
                 APred (VF Plain Pos) => plain ;
                 APred vf => verb.s ! vf }
     } ;

  AdjPhrase : Type = Adjective ** {compar : Str} ;
--------------------------------------------------------------------------------
-- Verbs

  BaseVerb : Type = {
    type : VerbType ;
    sc : NForm ; -- subject case
    } ;
  Verb : Type = BaseVerb ** {
    s : VForm => Str ;
    } ;
  Verb2 : Type = Verb ** {c2 : NForm ; p2 : Postposition} ;
  Verb3 : Type = Verb2 ** {c3 : NForm ; p3 : Postposition} ;

--  VV : Type = Verb ** {vvtype : VVForm} ;

  mkVerb : (plain : Str) -> VerbType -> Verb = \plain,vt ->
    let stem = init plain ;
        plainpres = case vowFinal stem of {
                      True  => add_N stem + "다" ;
                      False => stem + "는다" } ;
        informal = case vowFinal stem of { -- not used in grammar yet
                     True  => add_eo stem ;
                     False => stem + "어" } ;
        polpres = informal + "요" ;
        formalpres = case vowFinal stem of {
                       True  => add_B stem + "니다" ;
                       False => stem + "습니다" } ;
        neg = stem + "지" ;
    in mkVerbReg plainpres polpres formalpres neg vt ;

  mkVerb2 : (plain : Str) -> Verb2 = \plain -> vtov2 (mkVerb plain Active) ;
  mkVerb3 : (plain : Str) -> Verb3 = \plain -> v2tov3 (mkVerb2 plain) ;

  vtov2 : Verb -> Verb2 = \v -> v ** {c2 = Object ; p2 = emptyPP} ;
  v2tov3 : Verb2 -> Verb3 = \v -> v ** {c3 = Bare ; p3 = datPP} ;

  mkVerbReg : (x1,_,_,x4 : Str) -> VerbType -> Verb =
    \plainpres,polite,formal,neg,vt ->
    let planeg  = neg ++ negForms ! Plain ;
        polneg  = neg ++ negForms ! Polite ;
        formneg = neg ++ negForms ! Formal ;
     in mkVerbFull plainpres polite formal planeg polneg formneg vt ;

  mkVerbFull : (x1,_,_,_,_,x6 : Str) -> VerbType -> Verb =
    \plainpres,polite,formal,planeg,polneg,formneg,vt -> {
      s = table {
        VF Plain Pos => plainpres ;
        VF Plain Neg => planeg ;
        VF Polite Pos => polite ;
        VF Polite Neg => polneg ;
        VF Formal Pos => formal ;
        VF Formal Neg => formneg
      } ;
      type = vt ;
      sc = Subject
    } ;

  copula : Verb = mkVerbFull
    "이다"
    "이에요" -- or "이세요" ?
    "입니다"
    "아니다"
    "아니에요"
    "아닙니다"
     Copula ;

  copulaAfterVowel : Verb = copula ** {
    s = \\vf => case vf of {
                  VF Plain Pos  => "다" ;
                  VF Polite Pos => "예요" ;
                  _ => copula.s ! vf }
  } ;

  have_V : Verb = mkVerbFull
    "있다"
    "있어요"
    "있습니다"
    "없다"
    "없어요"
    "없습니다"
    Existential ;

  do_V : Verb = mkVerbReg
    "한다"
    "해요"
    "합니다"
    "하지"
    Active ;

  negForms : Style => Str =
    table { Plain => "않다" ;
            Polite => "않아요" ;
            Formal => "않습니다" } ;

------------------
-- Adv

  Adverb : Type = SS ;

------------------
-- VP

  Complement : Type = {
    s : VForm => Str ;
    -- compar : Str ; -- comparative is discontinuous
    } ;

  emptyComp : Complement = {
    s = \\_ => [] ;
    -- compar : Str ;
  } ;

  BaseVP : Type = {
    adv,
    nObj,
    vComp : Str
            -- {subjunc : Str ; -- inflected verb complement
            --  inf : Str ; -- infinitive verb complement
            --  subcl : Str} -- clause complement
    } ;

  baseVP : BaseVP = {
    adv,
    nObj,
    vComp = [] ;
  } ;

  VerbPhrase : Type = BaseVerb ** Complement ** BaseVP ;

  VPSlash : Type = Verb2 ** BaseVP ;

  useV : Verb -> VerbPhrase = \v -> baseVP ** v ;

  useVc : Verb2 -> VPSlash = \v2 -> baseVP ** v2 ;

  insertComp : VPSlash -> NounPhrase -> VerbPhrase = \v2,np -> useV v2 ** {
    nObj = np.s ! v2.c2 ++ v2.p2.s
  } ;

  insertAdv : VerbPhrase -> SS -> VerbPhrase = \vp,adv -> vp ** {adv = adv.s} ;
  insertAdvSlash : VPSlash -> SS -> VPSlash = \v,a -> v ** insertAdv v a ;
--------------------------------------------------------------------------------
-- Cl, S

  Clause : Type = {s : Tense => Anteriority => Polarity => Str} ;

  {- After PredVP, we might still want to add more adverbs (QuestIAdv),
     but we're done with verb inflection.
   -}
  ClSlash : Type = Clause ;

  QClause : Type = Clause ;

  RClause : Type = {s : NForm => Tense => Anteriority => Polarity => Str} ;

  Sentence : Type = {s : Str} ;

  predVP : NounPhrase -> VerbPhrase -> ClSlash = \np,vp -> vp ** {
    s = \\t,a,p => np.s ! vp.sc
                ++ vp.nObj -- an object, not copula complement
                ++ vp.adv
                ++ vp.s ! VF Polite p -- TODO: more tenses, choose politeness
    } ;

--------------------------------------------------------------------------------
-- linrefs

linVerb : Verb -> Str = \v -> v.s ! linVF ;

}
