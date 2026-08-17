
;; -
;; Placement reports
;; -

(defun placement-feedback-template ()
  (interactive)
  (insert
  "Strength:\n- \n\n"
  "Develop:\n- \n\n"
  "Develop:\n- \n\n"
  "Presentation:\n- \n\n"))
(global-set-key (kbd "C-c r") #'placement-feedback-template)

(defvar placement-comments
  '(

    ;; Reflection quality

    ("Too descriptive"
     . "The discussion tends towards description rather than reflection. Consider analysing what you learned, how your thinking developed, and what you would do differently in future.")

    ("Unstructured reflection"
     . "The reflective content is strong, but the discussion would benefit from a more structured and analytical style. Consider organising your discussion around a small number of key experiences, evaluating what was effective, what was not, and how your subsequent practice changed.")

    ("Well referenced but limited reflection"
     . "The section contains thoughtful observations about professional practice and engages with relevant literature. However, much of the discussion reads as a summary of conclusions reached at the end of the placement. To deepen the reflection, consider tracing how your understanding evolved over time by discussing the experiences, decisions, and feedback that led to these insights and how they subsequently affected your behaviour and performance.")

    ("Strong reflection"
     . "The report contains thoughtful reflection which moves beyond description to consider learning, development and future practice.")


    ;; Depth and synthesis

    ("Depth over breadth"
     . "The section identifies a number of interesting challenges, but many are discussed only briefly. Reflection is often strongest when a smaller number of significant experiences are explored in greater depth. Consider selecting one or two key examples and analysing the lessons learned in more detail.")

    ("Synthesising reflections"
     . "The report identifies several valuable learning experiences, but the reflection would be strengthened by considering how these experiences collectively shaped your understanding of professional practice. Consider drawing together related reflections into broader learning themes.")

    ("Specific and evidenced"
     . "The discussion would be strengthened by moving beyond general statements about personal growth and identifying specific experiences that contributed to the development of particular skills or attributes.")


    ;; Academic integration

    ("Weak module links"
     . "Strengthen the connection between workplace activities and specific modules, concepts or techniques from your degree programme.")

    ("Literature"
     . "Reflection is often strongest when personal experiences are considered alongside relevant literature or professional perspectives. Doing so allows you to compare your own observations with the experiences and ideas of others, helping you to challenge, confirm, or refine your understanding rather than relying solely on your own interpretation of events.")


    ;; Professional development

    ("Interpersonal reflection"
     . "Include deeper reflection on workplace interactions and how these experiences developed your professional skills.")

    ("Professional judgement"
     . "The reflection identifies an important learning experience. To deepen the analysis, consider relating your observations to wider professional practice or relevant literature, rather than presenting the lesson solely as a personal realisation.")

    ("Transferable learning"
     . "Consider moving beyond the specific details of the placement activity and reflecting on the broader lessons about professional practice, learning, communication or teamwork that may transfer to future roles and contexts.")

    ("Generic professional language"
     . "The experiences described are interesting and suggest genuine professional development. However, some of the discussion reads more as a summary of skills and opportunities than a critical reflection on their significance. Consider focusing on specific experiences and explaining how they influenced your thinking, interests, or future career intentions.")


    ;; Technical

    ("Technical challenge unclear"
     . "Clarify the technical challenge being addressed and explain why it was significant.")

    ("Limited evaluation"
     . "Evaluate the effectiveness of your approach in greater depth, considering strengths, limitations and possible improvements.")


    ;; Positive comments

    ("Good structure"
     . "The report is clearly structured and professionally presented.")

    ("Positive development"
     . "The placement appears to have provided substantial opportunities for learning and development. It is pleasing to see the range of technical, professional and interpersonal skills that you have developed through these experiences.")))


(defun placement-insert-comment ()
(interactive)
(insert
(cdr
(assoc
(completing-read "Comment: "
placement-comments
nil t)
 placement-comments))))

(global-set-key (kbd "C-c p") #'placement-insert-comment)

