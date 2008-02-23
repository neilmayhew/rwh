module PrettyJSON
    (
      jvalue
    ) where

import SimpleJSON (JValue(..))
import Prettify (Doc, (<>), (<+>), char, double, enclose, encloseC, fsep, hcat, punctuate, text)
import Numeric (showHex)
import Data.Bits (shiftR, (.&.))

{-- snippet jvalue --}
jvalue :: JValue -> Doc
jvalue (JBool True) = text "true"
jvalue (JBool False) = text "false"
jvalue JNull = text "null"
jvalue (JNumber num) = double num
jvalue (JString str) = string str
{-- /snippet jvalue --}
jvalue (JObject obj) = series (encloseC '{' '}') field obj
jvalue (JArray ary) = series (encloseC '(' ')') jvalue ary

unicode :: Char -> Doc
unicode c | d < 0x10000 = ch d
          | otherwise = astral (d - 0x10000)
  where d = fromEnum c
        ch x = text "\\u" <> text (replicate (4 - length h) '0') <> text h
            where h = showHex x ""
        astral n = ch (a + 0xd800) <> ch (b + 0xdc00)
            where a = (n `shiftR` 10) .&. 0x3ff
                  b = n .&. 0x3ff

string :: String -> Doc
string = encloseC '\"' '\"' . hcat . map oneChar
    where oneChar c = case lookup c specials of
                        Just r -> text r
                        Nothing | c < ' ' || c > '\xff' -> unicode c
                                | otherwise             -> char c
          specials = zipWith ch "\b\n\f\r\t\\\"/" "bnrt\\\"/"
          ch a b = (a, '\\':[b])

series :: (Doc -> Doc) -> (a -> Doc) -> [a] -> Doc
series wrap item = wrap . fsep . punctuate (char ',') . map item

field :: (String, JValue) -> Doc
field (k,v) = string k <> char ':' <+> jvalue v

-- Not present in Text.PrettyPrint.HughesPJ.

--enclose :: Doc -> Doc -> Doc -> Doc
--enclose left right x = left <> x <> right

--encloseC :: Char -> Char -> Doc -> Doc
--encloseC left right x = char left <> x <> char right
