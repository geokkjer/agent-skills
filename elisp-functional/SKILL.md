---
name: elisp-functional
description: Write Emacs Lisp using functional programming idioms — higher-order functions, immutable data flow, threading macros, seq/map/cl-lib, and minimal side-effects. For Emacs 29/30 with native-comp and lexical-binding. Prefer this over imperative Elisp patterns.
license: MIT
compatibility: Emacs 29+ (lexical-binding required), Emacs 30.2 verified
metadata:
  source: https://github.com/geokkjer/agent-skills
---

# Elisp — Functional Style

Write Emacs Lisp the way the gods of lambda intended: pure functions, immutable data, composable pipelines, and side-effects confined to thin boundary layers. This isn't Common Lisp with fewer parentheses — it's a functional Lisp that happens to edit text for a living.

## Core Principles

### 1. Lexical Binding Is Not Optional

`lexical-binding: t` enables closures, real `let` scoping, and all the functional patterns below. Emacs 30 defaults to it; Emacs 29 requires opt-in.

```elisp
;; -*- lexical-binding: t -*-
```

If you see a file without this, add it. If someone tells you dynamic binding is fine, they are wrong. Dynamic binding is the `var` of the Elisp world.

### 2. Prefer Expressions Over Statements

Everything in Elisp is technically an expression, but some patterns read like statements. Avoid them.

**Do this:**
```elisp
(defun lookup-author (book)
  (if-let ((authors (map-elt book :authors)))
      (string-join authors ", ")
    "Anonymous"))
```

**Not this:**
```elisp
(defun lookup-author (book)
  (let ((authors (map-elt book :authors)))
    (if authors
        (mapconcat #'identity authors ", ")
      "Anonymous")))
```

The `if-let` / `when-let` / `and-let` macros (from `subr-x`) eliminate the intermediate binding and null check boilerplate. They're the `Option.map` of Elisp.

### 3. Pure Functions By Default, Side-Effects By Contract

A function should either compute something or change something, rarely both.

```elisp
;; Pure — maps data
(defun decorate-title (book)
  (thread-last book
    (map-elt :title)
    (format "📖 %s")))

;; Impure — visible effect
(defun display-decorated-book (book)
  (message "%s" (decorate-title book)))
```

When you must mutate (buffers, markers, process state), isolate it behind a descriptive name.

### 4. Compose With Threading Macros

`thread-first` (->) and `thread-last` (->>) are your pipe operators. Use them instead of nesting.

```elisp
;; Nested — hard to read
(cl-reduce #'+ (seq-filter #'numberp (seq-map #'length (list "a" "be" "cat"))))

;; Threaded — reads like a pipeline
(thread-last (list "a" "be" "cat")
  (seq-map #'length)
  (seq-filter #'numberp)
  (cl-reduce #'+))
```

Use `thread-first` when each step feeds as the **first** argument (common for `map-elt`, `gethash`, `plist-get`), and `thread-last` when feeding as the **last** argument (common for sequence operations).

## Toolbox: The Trifecta

### `seq.el` — Sequence Operations

Built-in since Emacs 25, still the right tool. Works on lists, vectors, and strings uniformly.

```elisp
(require 'seq)

(seq-map #'upcase '("a" "b" "c"))         ;; => ("A" "B" "C")
(seq-filter #'numberp '(1 a 2 b 3 c))      ;; => (1 2 3)
(seq-remove #'numberp '(1 a 2 b 3 c))      ;; => (a b c)
(seq-reduce #'+ (number-sequence 1 5) 0)    ;; => 15
(seq-find #'numberp '(a b 3 d))            ;; => 3
(seq-every-p #'numberp '(1 2 3))           ;; => t
(seq-some #'numberp '(a b 3 d))            ;; => t
(seq-take '(a b c d e) 3)                  ;; => (a b c)
(seq-drop '(a b c d e) 2)                  ;; => (c d e)
(seq-doseq (x (number-sequence 1 3))        ;; Iteration without setq
  (message "%s" x))
```

**Key insight**: `seq-sort` and `seq-sort-by` let you sort functionally.

```elisp
(seq-sort-by #'length #'> '("cat" "aardvark" "be"))
;; => ("aardvark" "cat" "be")
```

### `cl-lib` — The Common Lisp Heritage

One of the few good things to come from the Common Lisp wars. All prefixed with `cl-`.

```elisp
(require 'cl-lib)

(cl-reduce #'+ '(1 2 3 4 5))                ;; => 15
(cl-find-if #'numberp '(a b 3 d))           ;; => 3
(cl-count-if #'numberp '(a 1 b 2 c 3))      ;; => 3
(cl-every #'numberp '(1 2 3))               ;; => t
(cl-some #'numberp '(a 1 b))                ;; => 1
(cl-remove-if-not #'numberp '(1 a 2 b 3))   ;; => (1 2 3)
(cl-subsetp '(a b) '(a b c))                ;; => t

;; Lexical closures — real ones, thanks to lexical-binding
(cl-labels ((factorial (n)
             (if (<= n 1) 1
               (* n (factorial (1- n))))))
  (factorial 5))                             ;; => 120
```

**`cl-loop`** is powerful but imperative-looking. Use it when it genuinely reads better, not as a crutch.

```elisp
;; Acceptable — collection comprehension
(cl-loop for i from 1 to 5 collect (* i i))  ;; => (1 4 9 16 25)

;; Better as a pipeline
(thread-last (number-sequence 1 5)
  (seq-map (lambda (i) (* i i))))
```

### `map.el` — Dictionary Operations

Works with alists, hash-tables, and plists through a uniform interface.

```elisp
(require 'map)

(map-elt '((:a . 1) (:b . 2)) :b)            ;; => 2
(map-keys '((:a . 1) (:b . 2)))              ;; => (:a :b)
(map-values '((:a . 1) (:b . 2)))            ;; => (1 2)
(map-apply #'cons '((:a . 1) (:b . 2)))      ;; => ((:a . 1) (:b . 2))
(map-merge 'alist '((:a . 1)) '((:b . 2)))   ;; => ((:a . 1) (:b . 2))
(map-put! (make-hash-table) :key "val")      ;; Mutates! Use with care.
```

**Prefer `map-elt` over `assoc` / `cdr` / `alist-get`** — it's polymorphic and doesn't assume you know what a cons cell is.

## Pattern Matching with `pcase`

`pcase` is destructuring match. It's the `match` of Rust/OCaml, translated to S-expressions. Use it instead of nested `car/cdr` gymnastics.

```elisp
(defun classify-book (book)
  (pcase book
    ;; Destructure an alist
    ((map :title :format (app downcase fmt))
     (pcase fmt
       ("epub"  "📖 EPUB")
       ("pdf"   "📄 PDF")
       ("txt"   "📝 Plain text")
       (_       "❓ Unknown")))

    ;; Match a cons cell
    (`(,key . ,val)
     (format "Key-value: %s = %s" key val))

    ;; Match a vector
    ([a b c]
     (format "Vector: %s %s %s" a b c))

    ;; Catch-all
    (_ "Unrecognized format")))

;; Guards with 'and' and 'or'
(pcase some-value
  ((and `(,key . ,val)
        (guard (symbolp key)))
   (format "Symbol-keyed pair: %s" key))
  ((or 'nil '())
   "It's nothing"))
```

**When to use `pcase`:** Multiple branches with different shapes. For simple destructuring, `if-let` and `when-let` are cleaner.

## Data Structures: The Functional Way

### Use `cl-defstruct` for Named Records

```elisp
(cl-defstruct book
  (title "" :type string)
  (author "Unknown" :type string)
  (format "txt" :type string)
  (tags nil :type list))

;; Construct — keyword args, no positionals
(let ((b (make-book :title "The Hobbit" :author "Tolkien" :format "epub")))
  (book-title b))  ;; => "The Hobbit"

;; Copy with modifications — immutable update
(cl-copy-book b :title "The Silmarillion")  ;; new instance, original untouched

;; Also works with alists via type conversion
(setf (book-tags b) '(fantasy adventure))  ;; mutates! use for performance-critical paths only
```

**Prefer `cl-copy-*` over destructive `setf`** for the same reason you prefer `let` over `setq` — referential transparency.

### Emacs 30 Idiom: Alists as Immutable Maps

Alists (association lists) are the simplest functional map in Elisp. They're immutable by convention — `alist-get` with a `nil` default doesn't modify, and you `cons` new entries rather than mutating.

```elisp
;; Functional update — cons prepends, shadows old key
(defun set-setting (settings key value)
  (cons `(,key . ,value)
        (cl-remove key settings :key #'car :test #'equal)))

;; Usage
(defparameter *config* '((theme . dark) (font-size . 14)))
(setf *config* (set-setting *config* 'theme 'light))
;; => ((theme . light) (font-size . 14))
```

## Generators (Lazy Sequences)

Built-in since Emacs 25 via the `generator` library. Handy for infinite sequences without stack overflow.

```elisp
(require 'generator)

(iter-defun fibonacci ()
  "Generate infinite Fibonacci sequence."
  (let ((a 0) (b 1))
    (while t
      (iter-yield a)
      (psetq a b
             b (+ a b)))))

;; Take the first 10
(thread-last (fibonacci)
  (seq-take 10))  ;; => (0 1 1 2 3 5 8 13 21 34)
```

**Caveat**: Generators are slower than `cl-loop` or recursion. Use them when you need laziness (infinite sequences, streaming data), not as a general iteration replacement.

## Anti-Patterns to Avoid

### ❌ `setq` in function bodies (almost always)

```elisp
;; Bad — imperative, hard to refactor
(defun process-books (books)
  (let ((result nil))
    (dolist (b books)
      (when (book-active-p b)
        (push (book-title b) result)))
    (nreverse result)))

;; Good — declarative pipeline
(defun process-books (books)
  (thread-last books
    (seq-filter #'book-active-p)
    (seq-map #'book-title)))
```

### ❌ `car`/`cdr` chains

```elisp
;; Bad — cryptic, easy to get wrong
(caddar (assoc 'metadata book))

;; Good — named accessor or pcase
(map-elt (map-elt book :metadata) :some-key)
```

### ❌ Nested `if` without `cond` or `pcase`

```elisp
;; Bad — staircasing
(if (eq fmt 'epub)
    (handle-epub)
  (if (eq fmt 'pdf)
      (handle-pdf)
    (if (eq fmt 'txt)
        (handle-text)
      (error "Unknown format"))))

;; Good — pattern match
(pcase fmt
  ("epub" (handle-epub))
  ("pdf"  (handle-pdf))
  ("txt"  (handle-text))
  (_      (error "Unknown format: %s" fmt)))
```

### ❌ `dolist` with accumulators when `seq-map`/`seq-filter` work

```elisp
;; Bad — manual accumulation
(let ((result ()))
  (dolist (item items result)
    (when (valid-p item)
      (push (transform item) result))))

;; Good — pipeline
(thread-last items
  (seq-filter #'valid-p)
  (seq-map #'transform))
```

## Emacs 30 Specifics

### Native Compilation

Emacs 30 compiles Elisp to native code via `libgccjit`. This means functional abstractions (closures, `seq-map`, `cl-reduce`) are no longer slower than imperative loops. The compiler inlines and optimizes through them.

You control it via:
```elisp
;; How many parallel compiler processes (defaults to 0, single-threaded)
(setopt native-comp-async-jobs-number 4)

;; Emit warnings during native compilation
(setopt native-comp-async-report-warnings-errors t)
```

### `key-valid-p` in `subr-x`

Rather than rolling your own key format validation:

```elisp
(key-valid-p "C-c C-f")    ;; => t
(key-valid-p "M-x")        ;; => t
(key-valid-p "C-🦀")        ;; => nil (yes, it validates)
```

### `use-package` Built-In

No more copy-pasting the bootstrap boilerplate from the README of every package you install. `use-package` is built into Emacs 29+.

```elisp
(use-package magit
  :ensure t
  :bind ("C-c g" . magit-status)
  :config
  (setopt magit-display-buffer-function
          #'magit-display-buffer-same-window-except-diff-v1))
```

This is declarative configuration. No `(require 'magit)`. No `(autoload ...)`. No imperative setup glue.

## Testing Functional Code

Use `ERT` (Emacs Lisp Regression Testing), built-in since Emacs 24.

```elisp
(require 'ert)

(ert-deftest test-lookup-author ()
  (should
   (equal (lookup-author '((:authors "Tolkien")))
          "Tolkien"))
  (should
   (equal (lookup-author '())
          "Anonymous")))

;; Run: M-x ert RET test-lookup-author RET
;; Or batch: emacs -batch -l test.el -f ert-run-tests-batch-and-exit
```

**Functional code is inherently testable** — pure functions have no setup, no mocking, no TeardownThatNobodyWrites(tm).

## When to Break the Rules

1. **Buffer-local state** — `setq-local`, `buffer-local-value`, and `let` around buffer modifications are fine. Just wrap them in `with-current-buffer` or `save-excursion`.

2. **Performance hot paths** — If profiling shows `seq-map` allocating a new list on every keystroke is the bottleneck, reach for `while` loops and `setq`. But measure first. Native compilation has narrowed the gap significantly.

3. **Interacting with external state** — File I/O, process management, and user input are side-effects by nature. Isolate them in thin wrapper functions and keep the business logic pure.

4. **Advice (advice-add)** — It's mutation of someone else's function. Functional purists hate it. But in practice, it's how you extend Emacs packages without forking. Own it, document it, keep it minimal.

## Style Summary

| Do | Don't |
|---|---|
| `seq-map` / `seq-filter` / `seq-reduce` | `dolist` + `push` + `nreverse` |
| `pcase` / `if-let` / `when-let` | Nested `if` / `car`-`cdr` gymnastics |
| `thread-first` / `thread-last` | Deeply nested function calls |
| `map-elt` / `map-keys` | `assoc` / `alist-get` without default |
| `cl-defstruct` with accessors | Manual plists with `plist-get` |
| `cl-flet` / `cl-labels` for local fns | `flet` (deprecated) |
| `cl-copy-*` for immutable updates | `setf` on everything |
| `use-package` declarative config | Imperative `(require ...)` + `(setq ...)` |

*The best Elisp reads like a dataflow diagram. Each function takes input, transforms it, passes it forward. Side-effects are the exception, not the rule. Code this way and Emacs will reward you with composable, debuggable, and dare we say, beautiful programs.*

## Reproducible Development Environment

This skill ships with a [Nix flake](flake.nix) that gives you a deterministic Elisp development environment. Same Emacs, same tools, same versions — on every machine, every time.

### What you get

- Emacs 30.2 with native compilation, tree-sitter, and XInput2
- `package-lint`, `relint`, `elisp-lint` — static analysis for your Elisp
- `buttercup` — BDD-style testing framework (complements ERT)
- `sly`, `helpful`, `rainbow-mode` — interactive development tools
- `ripgrep`, `fd` — fast file and content search
- `git`, `coreutils`, `shellcheck` — standard dev tooling

### Quick Start

```sh
# Enter the environment
nix develop ~/.agents/skills/elisp-functional

# Or for one-shot commands
nix develop ~/.agents/skills/elisp-functional --command emacs --version
```

### Using with direnv

Drop an `.envrc` in any Elisp project and `direnv allow`:

```bash
# .envrc — copy from the skill or write inline:
use flake ~/.agents/skills/elisp-functional
```

```sh
direnv allow   # Now Emacs 30.2 is in your PATH
```

### Locked for reproducibility

The `flake.lock` pins nixpkgs to a specific commit. Every time you `nix develop`, you get identical packages regardless of when or where you run it. Update the lockfile with:

```sh
nix flake lock --update-input nixpkgs
```

### Shell banner

When you enter the environment, you'll see:

```
=========================================================
  Elisp Development Environment
=========================================================
  Emacs:  GNU Emacs 30.2
  Native: yes
  System: x86_64-linux

  Run tests:   ert-runner (buttercup) or M-x ert
  Lint:        emacs -batch -f package-lint-current-buffer
  Regex check: emacs -batch -f relint-current-buffer

  The Elisp functional programming skill is loaded.
  Prefer seq-map, thread-last, and pcase over dolist and setq.
=========================================================
```
