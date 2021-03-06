import System.Random
import Data.List

-- http://www.haskell.org/haskellwiki/99_questions/21_to_28

-- 25
-- Generate a random permutation of the elements of a list.

randomPermutation :: [a] -> IO [a]
randomPermutation xs = randomSelect xs (length xs)
  
-- 24
-- Lotto: Draw N different random numbers from the set 1..M.

randomRange :: Int -> Int -> IO [Int]
randomRange num max = randomSelect [1..num] num

-- 23
-- Extract a given number of randomly selected elements from a list.
-- Prelude System.Random>rnd_select "abcdefgh" 3 >>= putStrLn
-- eda

randomSelect :: [a] -> Int -> IO [a]
randomSelect xs n = do
    randomGen <- getStdGen
    let indices = take n $ nub $ randomRs range randomGen
        range = (0, (length xs - 1))
    return $ map (xs !!) indices

-- 22
-- Create a list containing all integers within a given range.

range :: Int -> Int -> [Int]
range l h = [l..h]

range' :: Int -> Int -> [Int]
range' l h 
     | l == h   = [l]
     | l > h    = l : (range' (l - 1) h)
     | l < h    = l : (range' (l + 1) h)

-- 21
-- Insert an element at a given position into a list.
-- insertAt 'X' "abcd" 2
-- "aXbcd"

insertAt :: a -> [a] -> Int -> [a]
insertAt x xs i
    | i < 0             = error "i must be greater than or equal to zero"
    | i > length xs    = error "i must be smaller than or equal to the length of the list"
    | i == 0            = x : xs
    | otherwise         = head xs : (insertAt x t (i-1)) 
    where t = tail xs


-- http://www.haskell.org/haskellwiki/99_questions/11_to_20

-- 20
-- Remove the K'th element from a list.

removeAt :: [a] -> Int -> [a]
removeAt l i
    | i >= length l = error "i too big"
    | i == 0        = t
    | otherwise     = head l : (removeAt t (i-1)) 
    where t = tail l

-- 19
-- Rotate a list N places to the left.
-- Hint: Use the predefined functions length and (++).
-- Examples in Haskell:
-- 
-- *Main> rotate ['a','b','c','d','e','f','g','h'] 3
-- "defghabc" 
-- *Main> rotate ['a','b','c','d','e','f','g','h'] (-2)
-- "ghabcdef"

rotate :: [a] -> Int -> [a]
rotate [] _ = []
rotate x 0 = x
rotate x y
  | y > 0 = rotate (tail x ++ [head x]) (y-1)
  | otherwise = rotate (last x : init x) (y+1)

-- 18
-- Extract a slice from a list.
-- Given two indices, i and k, the slice is the list containing the elements between the i'th and k'th element of the original list (both limits included). Start counting the elements with 1.
-- Example in Haskell:
-- *Main> slice ['a','b','c','d','e','f','g','h','i','k'] 3 7
-- "cdefg"



slice :: Int -> Int -> [a] -> [a]
slice i k xs =
    [fst x | x <- zip xs [1..], (snd x >= from) && (snd x <= to)]
        where
            from = min i k
            to = max i k
-- 17
-- Split a list into two parts; the length of the first part is given.
-- Do not use any predefined predicates.

split :: Int -> [a] -> ([a],[a])
split n xs 
    | n < 0         = error "n < 0"
    | n > length xs = error "n > length"
    | otherwise     = (elementsUpToN,elementsAboveN)
    where
        elementsUpToN = [fst x | x <- indexedElements, snd x < n]
        elementsAboveN = [fst x | x <- indexedElements, snd x >= n]
        indexedElements = zip xs [0..]


-- 16
-- Drop every N'th element from a list.
-- dropEvery "abcdefghik" 3
-- "abdeghk"

dropEvery :: Int -> [a] -> [a]
dropEvery _ [] = []
dropEvery n xs = take (n-1) xs ++ dropEvery n (drop n xs)

-- 14
-- Duplicate the elements of a list.

duplicate :: [a] -> [a]
duplicate xs = foldr (\x acc -> x : x : acc) [] xs

-- 13
-- Run-length encoding of a list (direct solution).
-- Implement the so-called run-length encoding data compression method directly. I.e. don't explicitly create the sublists containing the duplicates, as in problem 9, but only count them. As in problem P11, simplify the result list by replacing the singleton lists (1 X) by X.

-- encodeDirect "aaaabccaadeeee"
-- [Multiple 4 'a',Single 'b',Multiple 2 'c', Multiple 2 'a',Single 'd',Multiple 4 'e']

encodeDirect :: Eq a => [a] -> [Element a]
encodeDirect [] = []
encodeDirect (x:xs) = reverse $ foldl f [Single x] xs
    where
        f acc x = if(equalsHead) then addToHead else prependToHead
            where 
                equalsHead = x == value headElement
                addToHead = (Multiple ((arity headElement) + 1) x) : tail acc 
                prependToHead = (Single x) : acc 
                headElement = head acc

value (Single x) = x
value (Multiple _ x) = x

arity (Single _) = 1
arity (Multiple n _) = n

-- 12
-- Decode a run-length encoded list.
-- Given a run-length code list generated as specified in problem 11. Construct its uncompressed version.

-- decodeModified [Multiple 4 'a',Single 'b',Multiple 2 'c', Multiple 2 'a',Single 'd',Multiple 4 'e']
-- "aaaabccaadeeee"
-- (a -> b -> b) -> b -> [a] -> b
decodeModified :: [Element a] -> [a]
decodeModified xs = foldr f [] xs
    where
        f x acc =  (extract x) ++ acc
        extract (Single x) = [x]
        extract (Multiple l x) = replicate l x

-- 11
-- Modified run-length encoding.
-- Modify the result of problem 10 in such a way that if an element has no duplicates it is simply copied into the result list. Only elements with duplicates are transferred as (N E) lists.

-- encodeModified "aaaabccaadeeee"
-- [Multiple 4 'a',Single 'b',Multiple 2 'c', Multiple 2 'a',Single 'd',Multiple 4 'e']

data Element a = Multiple Int a | Single a deriving Show

encodeModified :: Eq a => [a] -> [Element a]
encodeModified xs = map mappingFunc $ encode xs 
    where 
        mappingFunc (len, val) = if len == 1 then Single val else Multiple len val

-- http://www.haskell.org/haskellwiki/99_questions/1_to_10

-- 10
-- Run-length encoding of a list. Use the result of problem P09 to implement the so-called run-length encoding data compression method. Consecutive duplicates of elements are encoded as lists (N E) where N is the number of duplicates of the element E.

-- encode "aaaabccaadeeee"
--[(4,'a'),(1,'b'),(2,'c'),(2,'a'),(1,'d'),(4,'e')]

encode :: Eq a => [a] -> [(Int,a)]
encode xs = map makeTuple packedXs
    where
        makeTuple x = (length x, head x)
        packedXs = pack xs

-- 9
-- Pack consecutive duplicates of list elements into sublists. If a list contains repeated elements they should be placed in separate sublists.

-- *Main> pack ['a', 'a', 'a', 'a', 'b', 'c', 'c', 'a', 'a', 'd', 'e', 'e', 'e', 'e']
-- ["aaaa","b","cc","aa","d","eeee"]

pack :: (Eq a) => [a] -> [[a]]
pack [] = []
pack (x:xs) = (x : takeWhile (==x) xs) : pack (dropWhile (==x) xs)

-- 8
-- Eliminate consecutive duplicates of list elements.

compress :: Eq a => [a] -> [a]
compress = foldr prependIfNotSameAsHead []
    where
        prependIfNotSameAsHead x xs = if(isSameAsHead x xs) then xs else x:xs
        isSameAsHead x xs = length xs > 0 && x == head xs

-- 7
-- Flatten a nested list structure.

data NestedList a = Elem a | List [NestedList a]

flatten :: NestedList a -> [a]
flatten (Elem x) = [x]
flatten (List xs) = foldr (\x acc -> flatten x ++ acc) [] xs 

-- 6
-- Find out whether a list is a palindrome. A palindrome can be read forward or backward; e.g. (x a m a x).

isPalindrome :: Eq a => [a] -> Bool
isPalindrome []     = False
isPalindrome (x:[]) = True
isPalindrome xs = (take (start) xs) == (reverse (drop (end) xs))
    where 
        start = floor middle
        end = ceiling middle
        middle = ((fromIntegral len) / 2.0)
        len = length xs        

-- 5
-- Reverse a list.
reverse' :: [a] -> [a]
reverse' [] = []
reverse' (x:xs) = reverse' xs ++ [x]


-- 4
-- Find the number of elements of a list.
length' :: [a] -> Int
length' [] = 0
length' (x:xs) = 1 + length' xs

-- 3
-- Find the K'th element of a list. The first element in the list is number 1.
elementAt :: [a] -> Int -> a
elementAt _ 0 = error "Not found"
elementAt [x] 1 = x
elementAt (x:xs) 1 = x
elementAt (x:xs) k = elementAt xs (k-1)

-- 2
butLast' :: [a] -> [a]
butLast' [] = error "List must not be empty!"
butLast' [x] = []
butLast' (x:xs) = x : butLast' xs

-- 1 
last' :: [a] -> a
last' [] = error "List must not be empty!"
last' [x] = x
last' (_:xs) = last' xs

