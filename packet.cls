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
\RequirePackage{enumerate}
\RequirePackage{enumitem}
\RequirePackage{hyperref}

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
\def\claim#1{\par\noindent\hspace{-10mm}\makebox[10mm][r]{#1\enskip}\ignorespaces}
\def\endclaim{\par\medskip}
\newenvironment{lb}{\claim}{\endclaim}
\newenvironment{question}{\begin{lb}{\refstepcounter{question}\arabic{question}.\hyperdef{tossup}{\arabic{question}}{}}}{\end{lb}}

\newcommand{\power}[1]{{\textbf{#1}}}
\newcommand{\req}[1]{{\textbf{\uline{#1}}}}
\newcommand{\answer}[1]{{\textsc{answer}: #1}}
\newcommand{\partvalue}[1]{{[#1]}}
%%% END SEMANTICS


\newcommand{\tournamentname}{}
\newcommand{\tournamentyear}{}
\newcommand{\subtitle}{}

\newcommand{\packet}{Packet}

\newif\iffirstpacket\firstpacketfalse
\newif\ifnolastpacket\nolastpacketfalse
\newcommand{\lastpacketname}{}
\newcommand{\lastpacketone}{}
\newcommand{\lastpackettwenty}{}

\linespread{1.15}
\widowpenalties 1 10000
\raggedbottom

\renewcommand{\maketitle}{\noindent
\tournamentname{} \tournamentyear{}: \subtitle{}\\
\textbf{%{\packet{}} {\packetnumber{}} --- {
\packetname}\\
by \authors{}

\medskip
\begin{lb}{☞}
Please verify that the last packet was \textit{\lastpacketname}%
\iffirstpacket\else
\ifnolastpacket\else, which began with a tossup on \lastpacketone{} and ended with one on \lastpackettwenty{}%
\fi\fi.
\end{lb}
}
