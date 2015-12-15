module Test.Main where

import Prelude

import Data.Array
import Data.Maybe
import Data.Monoid
import Data.Foldable
import Data.Int
import Data.Traversable
import Math (pow, sin, cos, pi, abs)

import Signal.DOM
import Signal.Time

import qualified Text.Smolder.HTML as H
import qualified Text.Smolder.Markup as H
import qualified Text.Smolder.HTML.Attributes as A

import Flare
import Flare.Drawing
import Flare.Smolder

-- Example 1

ui1 = pow <$> number "Base" 2.0
          <*> number "Exponent" 10.0

-- Example 2

ui2 = string_ "Hello" <> pure " " <> string_ "World"

-- Example 3

ui3 = sum (int_ <$> [2, 13, 27, 42])

-- Example 4
ui4 = number_ 5.0 / number_ 2.0

-- Example 5

coloredCircle hue radius =
  filled (fillColor (hsl hue 0.8 0.4)) (circle 50.0 50.0 radius)

ui5 = coloredCircle <$> (numberSlider "Hue"    0.0 360.0 1.0 140.0)
                    <*> (numberSlider "Radius" 2.0  45.0 0.1  25.0)

-- Example 6

data Language = English | French | German

toString English = "english"
toString French  = "french"
toString German  = "german"

greet English = "Hello"
greet French  = "Salut"
greet German  = "Hallo"

ui6 = (greet <$> (select "Language" English [French, German] toString))
      <> pure " " <> string "Name" "Pierre" <> pure "!"

-- Example 7

plot m n1 s time =
      filled (fillColor (hsl 333.0 0.6 0.5)) $
        path (map point angles)

      where point phi = { x: 100.0 + radius phi * cos phi
                        , y: 100.0 + radius phi * sin phi }
            angles = map (\i -> 2.0 * pi / toNumber points * toNumber i)
                         (0 .. points)
            points = 400
            n2 = s + 3.0 * sin (0.005 * time)
            n3 = s + 3.0 * cos (0.005 * time)
            radius phi = 20.0 * pow inner (- 1.0 / n1)
              where inner = first + second
                    first = pow (abs (cos (m * phi / 4.0))) n2
                    second = pow (abs (sin (m * phi / 4.0))) n3

ui7 = plot <$> (numberSlider "m"  0.0 10.0 1.0  7.0)
           <*> (numberSlider "n1" 1.0 10.0 0.1  4.0)
           <*> (numberSlider "s"  4.0 16.0 0.1 14.0)
           <*> lift animationFrame

-- Example 8

ui8 = traverse (intSlider_ 1 5) (1..5)

-- Example 9

ui9 = boolean_ false && boolean_ true

-- Example 10

graph xs width = outlined (outlineColor black <> lineWidth width)
                          (path points)
    where points = zipWith point xs (1 .. length xs)
          point x y = { x, y: toNumber y }

ui10 = graph <$> foldp cons [] (numberSlider "Position" 0.0 150.0 1.0 75.0)
             <*> numberSlider "Width" 1.0 5.0 0.1 1.0

-- Example 11

ui11 = foldp (+) 0 (button "Increment" 0 1)

-- Example 12

table h w = H.table $ foldMap row (0 .. h)
  where row i = H.tr $ foldMap (cell i) (0 .. w)
        cell i j = H.td (H.text (show i ++ "," ++ show j))

ui12 = table <$> intSlider_ 0 9 5 <*> intSlider_ 0 9 5

-- Example 13

actions = string "Add item:" "Orange" <**> button "Add" (flip const) cons

list = foldp id ["Apple", "Banana"] actions

ui13 = (H.ul <<< foldMap (H.li <<< H.text)) <$> list

-- Example 14

data Domain = HSL | RGB

showDomain HSL = "HSL"
showDomain RGB = "RGB"

toHTML c = H.div `H.with` (A.style $ "background-color:" ++ hex) $ H.text hex
  where hex = colorString c

ns l = numberSlider l 0.0

uiColor HSL = hsl <$> ns "Hue"        360.0  1.0 180.0
                  <*> ns "Saturation"   1.0 0.01   0.5
                  <*> ns "Lightness"    1.0 0.01   0.5
uiColor RGB = rgb <$> ns "Red"        255.0  1.0 200.0
                  <*> ns "Green"      255.0  1.0   0.0
                  <*> ns "Blue"       255.0  1.0 100.0

inner = runFlareHTML "controls14b" "output14" <<< map toHTML <<< uiColor

ui14 = select "Color domain" HSL [RGB] showDomain

-- Example 15

data Action = Increment | Decrement | Negate | Reset

label Increment = "+ 1"
label Decrement = "- 1"
label Negate    = "+/-"
label Reset     = "Reset"

perform :: Action -> Int -> Int
perform Increment = add 1
perform Decrement = flip sub 1
perform Negate    = negate
perform Reset     = const 0

ui15 = foldp (maybe id perform) 0 $
         buttons [Increment, Decrement, Negate, Reset] label

-- Example 16

light on = H.with H.div arg mempty
  where arg | on = A.className "on"
            | otherwise = mempty

ui16 = light <$> liftSF (since 1000.0) (button "Switch on" unit unit)


-- Render everything to the DOM

main = do
  runFlareShow     "controls1"   "output1"  ui1
  runFlare         "controls2"   "output2"  ui2
  runFlareShow     "controls3"   "output3"  ui3
  runFlareShow     "controls4"   "output4"  ui4
  runFlareDrawing  "controls5"   "output5"  ui5
  runFlare         "controls6"   "output6"  ui6
  runFlareDrawing  "controls7"   "output7"  ui7
  runFlareShow     "controls8"   "output8"  ui8
  runFlareShow     "controls9"   "output9"  ui9
  runFlareDrawing "controls10"  "output10" ui10
  runFlareHTML    "controls12"  "output12" ui12
  runFlareShow    "controls11"  "output11" ui11
  runFlareHTML    "controls13"  "output13" ui13
  runFlareWith    "controls14a"     inner  ui14
  runFlareShow    "controls15"  "output15" ui15
  runFlareHTML    "controls16"  "output16" ui16
