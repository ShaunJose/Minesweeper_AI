-- @author: Shaun Jose --
{-# LANGUAGE OverloadedStrings #-}
module Main where

-- imports
import System.Random

-- DATA CREATION --

-- Modelling a cell in minesweeper --
data Value = Mine | Num Int -- Value = What's in the cell?
                deriving (Eq, Show)
data Status = Hidden | Shown | Flagged -- Status = status of cell
                deriving (Eq, Show)
type RowNum = Int -- rownumber (from 0 to rows-1)
type ColNum = Int -- columnNumber (from 0 to cols-1)
data Cell = Cell (RowNum, ColNum) Value Status  -- Cell definition --
              deriving (Eq, Show)

-- Modeeling the board --
-- Board is a list of cells
type Board = [Cell]

-- FUNCS --

-- applies function to neighbouring cells of cell provided, in the board
gridMap :: Board -> (Cell -> Cell) -> Cell -> Board
gridMap [] _ _ = []
gridMap ((Cell (row, col) val status) :board) func cell =
  let cellNums = gridList cell
    in case (isMember (row, col) cellNums) of
      True  -> (func (Cell (row, col) val status)) : gridMap board func cell
      False -> (Cell (row, col) val status) : gridMap board func cell

-- returns a list of locations of neighbouring-cells (exclusive of centre cell's location) NOTE that rows and cols returned may be out of bounds
gridList :: Cell -> [(RowNum, ColNum)]
gridList (Cell (row, col) _ _) =
  [(row-1, col-1), (row-1, col), (row-1, col+1),
   (row, col-1), {- (row, col), -} (row, col+1),
   (row+1, col-1), (row+1, col), (row+1, col+1)]

-- increment the mine count of an element in a cell
incrCellElem :: Cell -> Cell
incrCellElem (Cell (r, c) (Num i) status) = Cell (r, c) (Num (i+1)) status
incrCellElem cell = cell -- for mine-cell cases

-- Creating the board --
-- Create the board with all cells Hidden, and place chosen Mines
createBoard :: RowNum -> ColNum -> RowNum -> [(RowNum, ColNum)] -> Board
createBoard rows cols currRow mines | rows == currRow = []
createBoard rows cols currRow mines =
  (createRow currRow cols 0 mines) ++ (createBoard rows cols (currRow + 1) mines)

-- create a row (a list of cells), intialised all to Num 0 and Hidden
-- NOTE: This function also places the mines in the appropriate cells
createRow :: RowNum -> ColNum -> ColNum -> [(RowNum, ColNum)] -> Board
createRow row cols currCol mines | cols == currCol = []
createRow row cols currCol mines =
  let cellNum = (row, currCol)
    in case (isMember cellNum mines) of
      False   -> Cell cellNum (Num 0) Hidden : createRow row cols (currCol+1) mines
      otherwise -> Cell cellNum Mine Hidden : createRow row cols (currCol+1) mines

-- [ [Cell (0, 0), Cell (0, 1), Cell (0, 2) Cell (0, 3)],
--   [Cell (1, 0), Cell (1, 1), Cell (1, 2) Cell (1, 3)],
--   [Cell (2, 0), Cell (2, 1), Cell (2, 2) Cell (2, 3)] ]

-- random Int generator (within bounds)
makeRandomInt :: StdGen -> (Int, Int) -> (Int, StdGen)
makeRandomInt g bounds = randomR bounds g

-- random Int tuple generator (within certain bounds)
makeRandIntTuple :: StdGen -> (Int, Int) -> ((Int, Int), StdGen)
makeRandIntTuple g bounds =
              let firstRes = makeRandomInt g bounds
                in let secondRes = makeRandomInt (snd firstRes) bounds
                  in ((fst firstRes, fst secondRes ), snd secondRes)

-- random Int tuple list generator (with no duplicate tuples)
-- NOTE: This GENERATES RANDOM MINES' LOCATIONS (unique mine locations)
randIntTupleList :: StdGen -> (Int, Int) -> [(Int, Int)] -> Int -> ( [(Int, Int)], StdGen)
randIntTupleList g (_, _) currLst 0 = (currLst, g)
randIntTupleList g bounds currLst count =
  let randRes = makeRandIntTuple g bounds -- get (randIntTuple, new StdGen)
    in let tuple = fst randRes -- get randIntTuple
      in let gen = snd randRes -- get the new StdGen
        in case (isMember tuple currLst) of
          False      -> randIntTupleList gen bounds (tuple:currLst) (count-1)
          otherwise  -> randIntTupleList gen bounds currLst count

-- checks if in alement exists in a list
isMember :: (Eq a) => a -> [a] -> Bool
isMember _ []        = False
isMember elem (x:xs) = case (elem == x) of
                        True  -> True
                        False -> isMember elem xs

-- initialise game --
initGame :: Int -> IO ()
initGame 0 = getChar >>= putChar
initGame 1 = getChar >>= putChar
initGame n   = getChar >>= putChar

-- Main
main = do
        print $ Cell (0,1) (Num 1) Hidden == Cell (0,1) (Num 1) Hidden --Eq test
        print $ Cell (0,1) (Num 1) Hidden == Cell (1,1) (Num 1) Hidden --Eq test
        g <- getStdGen
        print $ fst $ makeRandomInt g (1, 7) -- makeRandomInt test
        print $ fst $ makeRandIntTuple g (1, 7) -- makeRandIntTuple test
        print $ randIntTupleList g (1, 2) [] 4 -- randomTupleList test
        print $ createRow 1 4 0 (fst $ randIntTupleList g (1, 2) [] 4) --createRow with mines Test
        print $ createBoard 10 4 0 (fst $ randIntTupleList g (1, 2) [] 4) --create Board with mines Test
        print $ gridList (Cell (2,1) (Num 0) Hidden) -- gridList test
        print $ incrCellElem (Cell (2,1) (Num 0) Hidden)
        print $ gridMap (createBoard 10 4 0 (fst $ randIntTupleList g (1, 2) [] 4)) incrCellElem (Cell (2,1) (Num 0) Hidden) -- gridMap + incrElem test
