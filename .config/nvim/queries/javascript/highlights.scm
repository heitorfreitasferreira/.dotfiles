; inherits: ecma,jsx

; Strudel built-in standalone functions
(call_expression
  function: (identifier) @function.builtin
  (#match? @function.builtin "^(s|note|cutoff|room|delay|bank|gain|slow|fast|rev|degrade|sometimes|every|stack|cat|chord|arp|scale|hush|setcpm|sound|n)$"))

; Strudel chained method calls
(member_expression
  property: (property_identifier) @function.builtin
  (#match? @function.builtin "^(s|note|cutoff|room|delay|bank|gain|slow|fast|rev|degrade|sometimes|every|struct|stutter|attack|decay|sustain|release|cut|n|speed|begin|end|legato|vowel|crush|distort|tremolo|phaser|chorus|delayfeedback|delaytime|sine|cosine|saw|square|tri|range|scale|arp|layer|bank|midi|midichan|midicmd|ccn|ccv|progNum|superdirt)$"))

; Mini-notation strings (double-quoted)
(
  (string) @string.special
  (#match? @string.special "^\"")
)

; Multi-line template patterns (backtick strings)
(template_string) @string.special
