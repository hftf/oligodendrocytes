% packet.cls
%  Typesets quizbowl packets
%
% 2013-03-22
% Ophir Lifshitz
% hangfromthefloor@gmail.com

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{packet}[2013/03/22 Typesets quizbowl packets]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions \relax
\LoadClass{article}

% LAYOUT
\RequirePackage[hmargin=0.75in,vmargin=0.75in]{geometry}
\RequirePackage{fancyhdr}
\RequirePackage{enumerate}
\RequirePackage{enumitem}

% TYPOGRAPHY
\RequirePackage[normalem]{ulem}

\RequirePackage{mathspec}
\RequirePackage{xltxtra}
\RequirePackage{xunicode}
\defaultfontfeatures{Mapping=tex-text}
\RequirePackage{fontspec}
\newcommand{\myfont}{Brill}
\setmainfont[Ligatures={Common}]{\myfont}

%%% SEMANTICS
\newcounter{question}
\def\claim{\par\medskip\noindent\refstepcounter{question}%
\hspace{-10mm}\makebox[10mm][r]{\arabic{question}. }%
}
\def\endclaim{\par\medskip}
\newenvironment{question}{\claim}{\endclaim}

\newcommand{\power}[1]{{\textbf{#1}}}
\newcommand{\req}[1]{{\textbf{\uline{#1}}}}
\newcommand{\answer}[1]{{\textsc{answer}: #1}}
\newcommand{\partvalue}[1]{{[#1]}}
%%% END SEMANTICS


\newcommand{\tournamentname}{}
\newcommand{\tournamentyear}{}
\newcommand{\subtitle}{}

\newcommand{\packet}{Packet}

\linespread{1.15}
\widowpenalties 1 10000
\raggedbottom

\renewcommand{\maketitle}{\noindent
\tournamentname{} \tournamentyear{}: \subtitle{}\\
\textbf{%{\packet{}} {\packetnumber{}} --- {
\packetname}\\
by \authors{}
\par}
