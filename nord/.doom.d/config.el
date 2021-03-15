;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!
(add-to-list 'custom-theme-load-path (expand-file-name "~/.emacs.d/themes/"))

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "ayamir"
      user-mail-address "lgt986452565@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;

;; Font Config
;(setq doom-font (font-spec :family "Fira Code" :size 18 :weight 'Regular))

(defun +my/better-font()
  (interactive)
  ;; english font
  (if (display-graphic-p)
      (progn
        (set-face-attribute 'default nil :font (format "%s:pixelsize=%d" "JetBrainsMono Nerd Font" 18)) ;; 11 13 17 19 23
        ;; chinese font
        (dolist (charset '(kana han symbol cjk-misc bopomofo))
          (set-fontset-font (frame-parameter nil 'font)
                            charset
                            (font-spec :family "Sarasa UI SC")))) ;; 14 16 20 22 28
    ))

(defun +my|init-font(frame)
  (with-selected-frame frame
    (if (display-graphic-p)
        (+my/better-font))))

(if (and (fboundp 'daemonp) (daemonp))
    (add-hook 'after-make-frame-functions #'+my|init-font)
  (+my/better-font))

;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-nord)
;(load-theme 'nord-light t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Sync/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Project Path
(setq projectile-project-search-path '("~/go/src/learn/"))


;; Org Mode Config
(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

;; Shortcut
(map! :leader
      :desc "rainbow-mode"
      "r" #'rainbow-mode)
(map! :leader
      :desc "comment"
      "C-c" #'comment-line)
(map! :leader
      :desc "treemacs"
      "C-d" #'treemacs)

(map! :leader
      :desc "quickrun"
      "C-r" #'quickrun)

(require 'rainbow-mode)
(dolist (hook '(css-mode-hook
             html-mode-hook))
  (add-hook hook (lambda () (rainbow-mode t))))

;; Clipbroad
(setq select-enable-clipboard t)
(xclip-mode 1)

;; Neotree Config
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))

;; Golang Config
(require 'dap-go)
(map! :leader
      :desc "Debug"
      "d" #'dap-debug)

;; Haskell Config
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(setq haskell-process-type 'cabal-new-repl)

;; Rust Config
(after! rustic
  (setq rustic-lsp-server 'rust-analyzer))

;; Doom Modeline
(setq doom-modeline-height 20)
(setq doom-modeline-bar-width 3)

;; org-downoad
(use-package org-download
	  ;; Keybind：Ctrl + Shift + Y
	  :bind ("C-S-y" . org-download-clipboard)
	  :config
	  (require 'org-download)
	  ;; Drag and drop to Dired
	  (add-hook 'dired-mode-hook 'org-download-enable)
	  )

;； Org2tex
;(require 'org2ctex)
;(org2ctex-toggle t)

;; Tabs
(setq centaur-tabs-set-icons t)
(setq centaur-tabs-set-bar 'under)
(setq centaur-tabs-set-modified-marker t)
(setq centaur-tabs--buffer-show-groups t)
(setq uniquify-separator "/")
(setq uniquify-buffer-name-style 'forward)
(use-package centaur-tabs
  :bind ("C-c g" . centaur-tabs-toggle-groups)
  :bind ("C-c h" . centaur-tabs-backward)
  :bind ("C-c l" . centaur-tabs-forward)
  :bind ("C-c k" . centaur-tabs-kill-other-buffers-in-current-group)
  :bind ("C-c C-k" . centaur-tabs-kill-all-buffers-in-current-group))

;; Input
(use-package rime
  :custom
  (default-input-method "rime"))

(require 'rime)

(setq rime-user-data-dir "~/.local/share/fcitx5/rime")

(setq rime-posframe-properties
      (list :background-color "#2E3440"
            :foreground-color "#D8DEE9"
            :background "D8DEE9"
            :foreground "2E3440"
            :font "Sarasa Mono SC Nerd-13"
            :internal-border-width 2))
(setq default-input-method "rime"
      rime-show-candidate 'posframe)

(setq rime-disable-predicates
      '(rime-predicate-evil-mode-p
        rime-predicate-after-alphabet-char-p
        rime-predicate-prog-in-code-p))

(setq mode-line-mule-info '((:eval (rime-lighter))))
(setq rime-inline-ascii-trigger 'shift-l)
(setq rime-inline-ascii-holder ?x)

;; Company
;(setq +lsp-company-backends '(company-tabnine :with company-capf :separate))
(setq +lsp-company-backends '(company-tabnine))
(setq company-idle-delay 0)
(setq company-show-numbers t)

;; Git
(require 'git-gutter)
(global-git-gutter-mode t)
(git-gutter:linum-setup)
(add-hook 'ruby-mode-hook 'git-gutter-mode)

(global-set-key (kbd "C-x C-g") 'git-gutter)
(global-set-key (kbd "C-x v =") 'git-gutter:popup-hunk)
(global-set-key (kbd "C-x p") 'git-gutter:previous-hunk)
(global-set-key (kbd "C-x n") 'git-gutter:next-hunk)
(global-set-key (kbd "C-x v s") 'git-gutter:stage-hunk)
(global-set-key (kbd "C-x v r") 'git-gutter:revert-hunk)
(global-set-key (kbd "C-x v SPC") #'git-gutter:mark-hunk)
(custom-set-variables
 '(git-gutter:separator-sign "|"))
(set-face-foreground 'git-gutter:separator "yellow")
(custom-set-variables
 '(git-gutter:hide-gutter t))

;; Wakatime
(global-wakatime-mode t)
