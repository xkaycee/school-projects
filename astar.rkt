#lang racket

; Structure to store node's position, parent, g value, and h value. 
(define-struct node (x-cord y-cord parent-node g h))


; Heuristic: Manhattan Distance
; Calculated as coordinates of current square subtracting corresponding goal coordinates 
(define (heuristic current-cord goal)
  (+ (abs(- (car current-cord) (car goal)))
     (abs(- (cadr current-cord) (cadr goal)))))


; Function: delete node from list
(define (delete node l)
  (cond 
    ; if list is empty, return empty list
    [(null? l) '()]
    ; if the first element in the list equals the node, remove node
    [(equal? (car l) node) (delete node (cdr l))]
    ; else recursively evaluate the rest of the list
    [#t (cons (car l) (delete node (cdr l)))]))


; Function: find the f cost of node
; Calculated as f(n) = g(n) + h(n)
(define (f-cost a-node)
  (+ (node-g a-node) (node-h a-node)))


; Function: check if a node is already in a list (open/closed)
; xy = pair, l = list
(define (contains-node xy l)
  (cond
    ; if the list is empty, return false
    [(empty? l) #f]
    ; compare the given xy coordinates to first element's xy position in the list
    [(and 
      (equal? (car xy) (node-x-cord (car l)))
      (equal? (cadr xy) (node-y-cord (car l)))) (car l)]
    ; recursively compare the rest of the list with xy coordinates
    [#t (contains-node xy (cdr l))]))


; Function: creates a closed list of nodes from the coordinates of obstacles
; parameter l being passed is a closed list
(define (init-obstacles l)
  (cond
    ; if the list is empty, return empty list
    [(empty? l) '()]
    ; else recursively create nodes and add to closed list
    [#t (cons (node (caar l) (cadar l) '() '0 '0) 
              (init-obstacles (cdr l)))]))


; Function: find neighbouring squares (coordinates) of the given square
(define (get-neighbours cord grid-size)
  ; define the given square's x and y coordinates
  (define sq-x-cord (car cord))
  (define sq-y-cord (cadr cord))
  
  (cond
    ; if the given square is empty, return empty list
    [(empty? cord) '()]
    ; else determine the north (top), south (bottom), east (right), and west (left) direction
    ; append all pairs of coordinates to one list
    [#t (append 
         ; if neighbours are outside of given grid size, return empty list
         (if (> sq-x-cord 1) (list (list (- sq-x-cord 1) sq-y-cord)) '()) ; left
         (if (< sq-x-cord grid-size) (list (list (+ sq-x-cord 1) sq-y-cord)) '()) ; right
         (if (< sq-y-cord grid-size) (list (list sq-x-cord (+ sq-y-cord 1))) '()) ; top
         (if (> sq-y-cord 1) (list (list sq-x-cord (- sq-y-cord 1))) '()))])) ; bottom


; Function: finds the node with the minimum f cost value
(define (get-min-f-cost list cur-min-node)
  (cond 
    ; if list is empty, the current node is the node with min f cost
    [(null? list) cur-min-node]
    ; check the first element of the list and compare its f cost value to current min node
    ; if it is less than the current min node, recursively check the rest of the list (for another possible min node)
    [(< (f-cost (car list)) (f-cost  cur-min-node)) 
     (get-min-f-cost (cdr list) (car list))]
    ; else recursively check the rest of the list (for possible min node)
    [#t (get-min-f-cost (cdr list) cur-min-node)]))


; Function: Checks current node's neighbours and determines whether it's in the open or closed list
; if in open list, check and update g value (as necessary), else ignore if in closed list
(define (check-neighbours open-list closed-list neighbours current-node goal)
  (cond    
    ; if there are no more neighbours, return open list (we're done at this point)
    [(empty? neighbours) open-list]
    ; checks if current neighbour is in the closed list (i.e. contains-node does not return #f)
    ; if so, ignore and continue checking other neighbours
    [(not (equal? #f (contains-node (car neighbours) closed-list)))
     (check-neighbours open-list closed-list (cdr neighbours) current-node goal)]
    
    ; if current neighbour is NOT in the open list, then add its node to the open list
    [#t (begin
          ; shortcut for accessing the current neighbour if it exists in the open list (might be #f)
          (define cur-neighbour (contains-node (car neighbours) open-list))
          ; if the node exists in the open list, but the current path is better than the existing path
          ; then delete the old node data from the open list
          (cond 
            [(and (not (equal? #f cur-neighbour))
                  (< (+ (node-g current-node) 1) (node-g cur-neighbour)))
             (delete cur-neighbour open-list)])
          
          ; create a new node with the relevant data and put it into the open list
          ; recall that a node structure is (x-cord y-cord parent-node g h)
          (check-neighbours 
           (cons (node (caar neighbours) (cadar neighbours) current-node                                    
                       (+ (node-g current-node) 1) (heuristic (car neighbours) goal)) open-list) 
           closed-list (cdr neighbours) current-node goal))]))


; Function: retrace path after evaluating route to goal
(define (trace-path node)
  (cond 
    ; empty list represents that we have found by backtracking a path from goal to start
    [(equal? node '()) '()]
    ; recursively trace the path by following the node's parent 
    [#t (begin
          (define cord (list (node-x-cord node) (node-y-cord node)))
          (cons cord (trace-path (node-parent-node node))))]))


; Recursive A* call function
(define (a*-recursive open-list closed-list goal grid-size)
  ; set current node to the node with the lowest f cost 
  (define current-node (get-min-f-cost open-list (car open-list)))
  (define new-closed-list (cons current-node closed-list))
  ; new list is returned when we check a node's neighbours (always use the updated list)
  (define new-open-list (check-neighbours (delete current-node open-list) 
                                          new-closed-list 
                                          (get-neighbours (list (node-x-cord current-node) (node-y-cord current-node)) grid-size)
                                          current-node 
                                          goal))
  (cond
    ; if the open list is empty, then no path from start to goal exist
    [(empty? open-list) (display "No path exist\n")]
    ; check whether goal has been reached, if so return path
    [(contains-node goal (list current-node)) 
     (begin 
       (display "\npath found: \n")
       (display (reverse (trace-path current-node))))]
    ; else recursively execute with the new open and closed list
    [#t (a*-recursive new-open-list new-closed-list goal grid-size)]))


; Call A* with given parameters (main)
; INPUT: (grid-size start goal obstacles)
; obstacles must be entered, if null then input expected as ()
(define (astar parameters)
  (define grid-size (car parameters))
  (define start (cadr parameters))
  (define goal (caddr parameters))
  (define closed-list (init-obstacles (cadddr parameters)))
  
  (cond 
    ; if the grid size is n x n, call the function a*-recursive (recursive implementation of A*)
    [(equal? (car grid-size) (cadr grid-size)) 
     (a*-recursive (list (node (car start) (cadr start) '() 0 (heuristic start goal)))
                   closed-list
                   goal
                   (car grid-size))]
    ; else error: grid should be of size n x n (by specifications)
    [#t (display "Grid is not of size NxN")]))



#| ========== TEST CASES ========== |#

; Given test case. STATUS: PASS
(astar '((8 8) (2 2) (6 6) ((3 2) (3 3) (4 7) (5 2) (5 4) (5 5) (5 6) (5 7))))

#| path found: 
((2 2) (2 3) (2 4) (3 4) (4 4) (4 3) (5 3) (6 3) (6 4) (6 5) (6 6)) |#

;
(astar '((10 10) (9 2) (1 1) ((1 2) (1 6) (2 4) (2 8) (3 1) (3 2) (3 3)
                                    (3 4) (3 5) (3 7) (3 9) (4 7) (5 2)
                                    (5 4) (5 6) (5 8) (5 9) (5 10) (6 5)
                                    (7 1) (7 2) (7 8) (8 1) (8 2) (8 3)
                                    (8 5) (8 7) (8 8) (8 9) (9 1) (9 4)
                                    (9 6) (10 8))))

#| path found: 
((9 2) (10 2) (10 3) (10 4) (10 5) (10 6) (10 7) (9 7) (9 8) (9 9) (9 10) 
(8 10) (7 10) (7 9) (6 9) (6 8) (6 7) (6 6) (7 6) (7 5) (7 4) (7 3) (6 3) 
(5 3) (4 3) (4 4) (4 5) (4 6) (3 6) (2 6) (2 5) (1 5) (1 4) (1 3) (2 3) (2 2) (2 1) (1 1))|#




#|(astar '((100 100) (1 1) (100 100) ()))
(astar '((8 8) (2 2) (6 6) ((3 2) (5 2) (3 3) (4 7) (5 4) (5 5) (5 6) (5 7))))
(astar '((7 7) (2 3) (6 3) ((4 2) (4 3) (4 4))))
(astar '((8 8) (3 3) (4 4) ((4 3) (5 3) (6 3) (3 4) (3 5) (3 6))))
(astar '((8 8) (1 3) (5 3) ((2 2) (2 3) (2 4) (4 2) (4 3) (4 4) (5 5))))
(astar '((7 7) (4 1) (4 7) ((2 2) (2 3) (2 4) (2 5) (2 6) (3 6) (4 6) (5 6) (6 6) (6 5) (6 4) (6 3) (6 2))))
(astar '((15 15) (7 1) (15 15) ((1 2) (3 2) (5 2) (7 2) (9 2) (11 2) (13 2) (15 2)
                         (2 4) (4 4) (6 4) (8 4) (10 4) (12 4) (14 4)
                         (1 6) (3 6) (5 6) (7 6) (9 6) (11 6) (13 6) (15 6)
                         (2 8) (4 8) (6 8) (8 8) (10 8) (12 8) (14 8) 
                         (11 9) (12 9) (13 9) (14 9) (15 9)
                         (9 11) (10 10) (10 15) (10 14) (10 13)
                         (14 15) (14 14) (14 13) (14 12))))
|#


