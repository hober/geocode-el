;;; geocode.el --- geocoder.us API client for Emacs

;; Copyright (C) 2009  Edward O'Connor

;; Author: Edward O'Connor <hober0@gmail.com>
;; Keywords: convenience

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; This is my initial, very rough cut of an Elisp API client for
;; [geocoder.us][]. Depends on Ulf Jasper's [csv.el][]. A simple `make
;; csv.el` should fetch it for you.

;; This code has one entry point, `geocode`, which takes an address.

;; [geocoder.us]:     http://geocoder.us/
;; [csv.el]:          http://ulf.epplejasper.de/downloads/csv.el
;; [hober/md-readme]: http://github.com/hober/md-readme

;;; History:
;; 2009-11-16: Initial release.
;; 2009-11-17: Clean things up a bit. Checkdoc.
;; 2009-11-17: Adopt [hober/md-readme][] for README.md generation.

;;; Code:

(require 'csv)
(require 'url)

(defvar geocode-debug nil
  "If non-null, keep old response buffers for debugging purposes.")

(defun geocode (address)
  "Geocode ADDRESS.
Returns a plist containing the address' components and its lat/long."
  (geocode-parse-response
   (url-retrieve-synchronously
    (concat "http://rpc.geocoder.us/service/csv?address="
            (url-hexify-string address)))))

(defun geocode-parse-response (buffer)
  "Parse the CSV from geocoder.us in BUFFER."
  (unwind-protect
      (with-current-buffer buffer
        (url-http-parse-response)
        (narrow-to-region (1+ url-http-end-of-headers) (point-max))
        (let ((geoinfo (car (csv-parse-buffer nil))))
          (list :lat (string-to-number (nth 0 geoinfo))
                :long (string-to-number (nth 1 geoinfo))
                :street-address (nth 2 geoinfo)
                :locality (nth 3 geoinfo)
                :region (nth 4 geoinfo)
                :postal-code (nth 5 geoinfo))))
    (unless geocode-debug
      (kill-buffer buffer))))

(provide 'geocode)
;;; geocode.el ends here
