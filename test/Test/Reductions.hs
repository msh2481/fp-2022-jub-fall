module Test.Reductions where

import Constants
import Data.Function
import qualified Data.Set as Set
import Lambda
import Reductions
import Test.Tasty
import Test.Tasty.HUnit

unit_cas :: IO ()
unit_cas = do
  cas x sxy @?= y
  cas xy sxy @?= App y y
  cas lxy sxy @?= lxy
  cas (Abs "z" y) sxy @?= Abs "z" (Var "y")
  cas (Abs "z" x) sxy @?= Abs "z" (Var "y")
  cas (Abs "z" x) sxz @?= Abs "a" (Var "z")
  cas (Abs "y" x) sxz @?= Abs "y" (Var "z")
  cas (Abs "z" lzx) sxz @?= Abs "a" (App (Var "a") (Var "z"))
  cas (Abs "f" (Abs "x" (Var "f"))) (Subst "a" (Var "f")) @?= Abs "b" (Abs "x" (Var "b"))

nfafx :: Lambda
nfafx = App (App (Var "n") (Var "f")) (App (App (Var "a") (Var "f")) (Var "x"))

fxx :: Lambda
fxx = Abs "f" (Abs "x" (Var "x"))

ω :: Lambda
ω = Abs "x" (App x x)

ωω :: Lambda
ωω = App ω ω

k :: Lambda
k = Abs "x" (Abs "y" x)

unit_no :: IO ()
unit_no = do
  eval NormalOrder successor @?= Abs "n" (Abs "f" (Abs "x" (App (Var "f") (App (App (Var "n") (Var "f")) (Var "x"))))) --  "\\n.\\f.\\x.f (n f x)"
  eval NormalOrder mult @?= Abs "m" (Abs "n" (Abs "f" (App (Var "m") (App (Var "n") (Var "f"))))) -- "\\m.\\n.\\f.m (n f)"
  eval NormalOrder mult' @?= Abs "m" (Abs "n" (App (App (Var "m") (Abs "a" (Abs "f" (Abs "x" nfafx)))) fxx)) -- "\\m.\\n.m (\\a.\\f.\\x.n f (a f x)) (\\f.\\x.x)"
  eval NormalOrder twotimestwo @?= four
  evalMaybe NormalOrder twotimestwo 3 @?= Nothing
  eval NormalOrder twotimestwo' @?= four
  evalMaybe NormalOrder ω 10 @?= Just ω
  evalMaybe NormalOrder (App ω ω) 1000 @?= Nothing

alphaCmp :: Lambda -> Lambda -> Assertion
alphaCmp = (@?=) `on` toDeBruijn

unit_ao :: IO ()
unit_ao = do
  eval ApplicativeOrder mult `alphaCmp` eval NormalOrder mult
  eval ApplicativeOrder mult' `alphaCmp` eval NormalOrder mult'
  eval ApplicativeOrder onetimesone' `alphaCmp` eval NormalOrder onetimesone'
  eval ApplicativeOrder twotimestwo `alphaCmp` eval NormalOrder twotimestwo

unitTests :: [TestTree]
unitTests =
  [ testCase "cas" unit_cas,
    testCase "no" unit_no,
    testCase "ao" unit_ao
  ]