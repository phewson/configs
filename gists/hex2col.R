library(magrittr)

colhex2col <- function(colhex) {
    # Convert hex to RGB
    mycol   <- colhex %>% col2rgb()
    # Convert all x11 colors to RGB, adn transform
    colors()                 %>%        # Get X11 colors (hex)
        col2rgb              %>%        # Convert to RGB matrix
        data.frame           %>%        # Convert to data.frame
        setNames(.,colors()) %>%        # Set color names
        t                    %>%        # Transform so colors are in rows (columns: R,G,B)
        data.frame           %>%        # Re-convert to data.frame
        apply(.,1,function(x) sum(abs(x-mycol)) ) %>%  # For each color, calc the sum of diff between mycol RGB and the color RGB
        sort                 %>%        # Sort so color with smallest diff comes first
        '['(1)               %>%        # Get the first color in the df = closest
        names                %>%        # Return the name of the color
        return

}