module Test.ReductionsPB where

import Lambda
import Reductions
import Hedgehog
import Data.Maybe
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range
import Test.Tasty
import Test.Tasty.Hedgehog

genName :: Gen String
genName = Gen.list (Range.singleton 1) Gen.alphaNum

genLambda :: Gen Lambda
genLambda =
  Gen.recursive
    Gen.choice
    [ Lambda.Var <$> genName
    ]
    [ Gen.subtermM genLambda (\x -> Abs <$> genName <*> pure x),
      Gen.subterm2 genLambda genLambda App
    ]


prop_strategiesAreEquivalent :: Property
prop_strategiesAreEquivalent = property $ do
  term <- forAll $ genLambda
  let n = 1000
  let a = Reductions.evalMaybe NormalOrder term n >>= (Just . toDeBruijn)
  let b =  Reductions.evalMaybe ApplicativeOrder term n >>= (Just . toDeBruijn)
  assert (a == b)


props :: [TestTree]
props =
  [ testProperty "normal and applicative orders agree" prop_strategiesAreEquivalent
  ]