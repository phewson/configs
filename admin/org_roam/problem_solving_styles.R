library(shiny)
library(shinysurveys)
library(plotrix)

LIKERT5 <- c("Strongly agree", "Agree", "Neither agree nor disagree",
             "Disagree", "Strongly disagree")

create_get_point <- function(center_x, center_y) {
  get_point <- function(score, angle) {
    x <- center_x + score * cos(angle * pi / 180)
    y <- center_y + score * sin(angle * pi / 180)
    return(data.frame(x, y))
  }
  return(get_point)
}

plot_results <- function(results) {
  center_x <- 6
  center_y <- 6
  radius <- c(2, 4)
  par(xpd = NA)
  theta <- seq(0, 2 * pi, length.out = 100)
  x_circ <- center_x + radius[2] * cos(theta)
  y_circ <- center_y + radius[2] * sin(theta)
  plot(x_circ, y_circ,
       col = "#2da13a", type = "l", xaxt = "n", xlab = "", ylab = "",
       yaxt = "n", bty = "n", xlim = c(1, 11), ylim = c(1, 11),
       main = "Preferred problem-solving style")
  x_circ <- center_x + radius[1] * cos(theta)
  y_circ <- center_y + radius[1] * sin(theta)
  lines(x_circ, y_circ, lty = 2, col = "#2da13a")
  offset_angles <- c(45, 135, 225, 315)
  cardinal_angles <- c(0, 90, 180, 270)
  text_angles <- seq(from = 22.5, to = 360 - 22.5, by = 45)
  descriptive_text <- c("Organise", "Implement", "Market", "Create", "Play", "Discover",
                        "Appraise", "Conclude")
  get_point <- create_get_point(center_x, center_y)
  scores_df <- get_point(results[1, 1], offset_angles[1])
  for (i in c(2:4)) {
    scores_df <- rbind(scores_df, get_point(results[1, i], offset_angles[i]))
  }
  for (angle in offset_angles) {
    x <- center_x + radius[2] * cos(angle * pi / 180)
    y <- center_y + radius[2] * sin(angle * pi / 180)
    arrows(center_x, center_y, x, y, col = "grey", lwd = 2)
  }
  for (angle in cardinal_angles) {
    x <- center_x + radius[2] * 1.1 * cos(angle * pi / 180)
    y <- center_y + radius[2] * 1.1 * sin(angle * pi / 180)
    arrows(center_x, center_y, x, y, lty = 2, col = "grey", lwd = 2)
  }
  for (i in c(1:8)) {
    x <- center_x + radius[2] * 0.8 * cos(text_angles[i] * pi / 180)
    y <- center_y + radius[2] * 0.8 * sin(text_angles[i] * pi / 180)
    text(x, y, descriptive_text[i])
  }
  text(c(6, 11, 6, 1), c(11, 6, 1, 6), c("Rational", "Stage 2", "Intuition", "Stage 1"))
  points(scores_df, pch = 16, cex = 2, col = "#232173")
  for (i in c(1:4)) {
    arrows(scores_df[i, 1], scores_df[i, 2],
           scores_df[(i %% 4) + 1, 1], scores_df[(i %% 4) + 1, 2],
           length = 0, col = "#232173", lwd = 2)
  }
}

analyst <- c("I always or usually investigate throroughly before deciding",
             "I like to work precisely and slowly",
             "I will look for the causes of problems",
             "I prefer to prepare and study in advance",
             "I rely on and use facts to back my arguments (rather than hunches and intuition",
             "I ask 'what?' and 'why?' questions",
             "I am numerate",
             "I organise information carefully",
             "I know how to access appropriate databases to find relevant facts",
             "I look for differences and distinctions",
             "I apply rules in order to understand information",
             "I prefer a lot of detail on which to base decisions")

engineer <- c("I like to be in control of my work",
              "I like to make firm decisions",
              "I dislike inaction",
              "I prefer maximum freedom to manage myself and others for whom I am responsible",
              "I apply clear protocols in order to implement a solution",
              "I have a low tolerance for the feelings, attitudes and advice of others",
              "I am technically proficient",
              "I look for permanent solutions rather than quick fixes",
              "I am good at finding faults",
              "I ask 'how?' questions",
              "I am focussed",
              "I do not like to waste time")

explorer <- c("I like to seek unknown territory and new ideas",
              "I am self-motivated, almost to the point of being restless",
              "I trust my spontaneous insights",
              "I am interested in analogies and resemblances",
              "I am extremely curious",
              "I seem out ambiguity and uncertainty",
              "I ask 'what else?' and 'what if?' questions",
              "I look for unanswered questions",
              "I enjoy breaking rules",
              "I enjoy taking risks and working at the limits of my competence",
              "I like to take risks",
              "I am easly bored; I can find it hard to follow through or finish projects")

designer <- c("I think in pictures",
              "I seek patterns in information",
              "I ask 'why not?' questions",
              "I regard failure as an interesting learning opportunity",
              "I tend to dream",
              "I like to think about the 'big picture'",
              "I seek inspiration",
              "I try to cultivate 'style'",
              "I thrive on feedback",
              "I value the simplest and most elegant solution",
              "I like selling solutions",
              "I am capable of judging my own ideas objectively")

problem_solving_questions <- data.frame(a = analyst, n = engineer, x = explorer, d = designer)

create_mc_question <- function(options) {
  mc_question <- function(question_wording, question_category, question_number) {
    df <- data.frame(question = rep(question_wording, 5), option = options,
                     input_type = rep("mc", 5),
                     input_id = rep(question_number, 5),
                     dependence = rep(NA, 5), dependence_value = rep(NA, 5),
                     required = rep(FALSE, 5))
    return(df)
  }
  return(mc_question)
}

mc_question <- create_mc_question(LIKERT5)

running_order <- sample(paste(rep(c("a", "n", "x", "d"), 12),
                              formatC(sort(rep(1:12, 4)), width = 2, format = "d", flag = "0"),
                              sep = ""))

get_lookups <- function(running_order, i) {
  problem_solving_type <- substring(running_order[i], 1, 1)
  colnum <- which(colnames(problem_solving_questions) == problem_solving_type)
  rownum <- as.numeric(substring(running_order[i], 2, 3))
  return(list(problem_solving_type = problem_solving_type, colnum = colnum, rownum = rownum))
}

gl <- get_lookups(running_order, 1)
df <- mc_question(problem_solving_questions[gl$rownum, gl$colnum], gl$problem_solving_type,
                  paste(gl$problem_solving_type, gl$rownum, sep = ""))
for (i in c(2:48)) {
  gl <- get_lookups(running_order, i)
  df <- rbind(df,
              mc_question(problem_solving_questions[gl$rownum, gl$colnum],
                          gl$problem_solving_type,
                          paste(gl$problem_solving_type, gl$rownum, sep = "")))
}

ui <- fluidPage(surveyOutput(df = df,
                             survey_title = "Preferred problem solving styles",
                             survey_description = "There are 48 questions"))

server <- function(input, output, session) {
  renderSurvey()
  observeEvent(input$submit, {
    analyst_r <- c(input$a1, input$a2, input$a3, input$a4, input$a5, input$a6,
                   input$a7, input$a8, input$a9, input$a10, input$a11, input$a12)
    engineer_r <- c(input$n1, input$n2, input$n3, input$n4, input$n5, input$n6,
                    input$n7, input$n8, input$n9, input$n10, input$n11, input$n12)
    explorer_r <- c(input$x1, input$x2, input$x3, input$x4, input$x5, input$x6,
                    input$x7, input$x8, input$x9, input$x10, input$x11, input$x12)
    designer_r <- c(input$d1, input$d2, input$d3, input$d4, input$d5, input$d6,
                    input$d7, input$d8, input$d9, input$d10, input$d11, input$d12)
    a_score <- length(grep("Strongly agree|Agree", analyst_r))
    e_score <- length(grep("Strongly agree|Agree", engineer_r))
    x_score <- length(grep("Strongly agree|Agree", explorer_r))
    d_score <- length(grep("Strongly agree|Agree", designer_r))
    results <- data.frame(a_score, e_score, x_score, d_score)

    showModal(modalDialog(renderPlot({plot_results(results)})
                 #  title = "Congrats, you completed your first shinysurvey!",
                 #  "You can customize what actions happen when a user finishes a survey using input$submit."
               ))
  })
}

shinyApp(ui, server)

