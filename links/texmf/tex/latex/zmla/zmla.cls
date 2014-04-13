\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{zmla}[4/10/14 ZML MLA]

\LoadClass[12pt]{article}

\RequirePackage{zmla}

\AtBeginDocument{\makeheader}
\AtEndDocument{\ifsources\makeworkscited\else\fi}
\endinput

