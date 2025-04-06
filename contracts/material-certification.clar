;; Material Certification Contract
;; Records fiber content and production methods

(define-data-var admin principal tx-sender)

;; Map of material certifications
(define-map material-certifications uint
  {
    producer: principal,
    material-type: (string-utf8 50),
    fiber-content: (string-utf8 200),
    production-method: (string-utf8 100),
    organic: bool,
    recycled-content: uint,
    certification-date: uint
  }
)

;; Counter for certification IDs
(define-data-var certification-id-counter uint u0)

;; Add a new material certification
(define-public (certify-material
    (producer principal)
    (material-type (string-utf8 50))
    (fiber-content (string-utf8 200))
    (production-method (string-utf8 100))
    (organic bool)
    (recycled-content uint))
  (begin
    ;; Check if producer is calling or admin is calling
    (asserts! (or (is-eq tx-sender producer) (is-eq tx-sender (var-get admin))) (err u1))

    ;; Get new ID and increment counter
    (let ((new-id (var-get certification-id-counter)))
      (var-set certification-id-counter (+ new-id u1))

      ;; Store certification
      (map-set material-certifications new-id
        {
          producer: producer,
          material-type: material-type,
          fiber-content: fiber-content,
          production-method: production-method,
          organic: organic,
          recycled-content: recycled-content,
          certification-date: block-height
        }
      )
      (ok new-id)
    )
  )
)

;; Get material certification details
(define-read-only (get-material-certification (certification-id uint))
  (map-get? material-certifications certification-id)
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (var-set admin new-admin)
    (ok true)
  )
)
