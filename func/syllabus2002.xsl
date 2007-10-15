<?xml version="1.0" encoding="euc-jp" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:output method="text" encoding="euc-jp"/>
  <!-- 2003年1月23日最終更新 -->
  <!-- シラバスXMLの文書ノードに対してTexの枠組みを出力する -->
  <xsl:template match="syllabus">
\documentclass[a4j,10pt]{jarticle}
\makeatletter
\def\Hline{%
\noalign{\ifnum0=`}\fi\hrule \@height 1pt \futurelet
\reserved@a\@xhline}
\makeatother
\usepackage{array}

\setlength{\textheight}{247mm}
\setlength{\textwidth}{172mm}
\setlength{\oddsidemargin}{-6.4mm}
\setlength{\evensidemargin}{-6.4mm}
\setlength{\voffset}{-12mm}

\pagestyle{empty}

% エラーの無視
%\batchmode

\begin{document}


\begin{center}
\begin{small}
{\renewcommand{\arraystretch}{1.5}
\begin{tabular}{ccccccccc}

% 【授業科目名】 現科目名 〈旧科目名〉 (英文科目名 〈旧英文科目名〉)
\multicolumn{1}{l}{\parbox[c]{7zw}{
{\textbf{\normalsize 【授業科目名】}}
}} <xsl:text disable-output-escaping="yes">&amp;</xsl:text> <xsl:text> </xsl:text>
\multicolumn{4}{l}{\parbox[c]{18zw}{
{\textbf {\normalsize <xsl:value-of select="subject_name/name_ja"/>}}
}} <xsl:text disable-output-escaping="yes">&amp;</xsl:text> <xsl:text> </xsl:text>
\multicolumn{4}{l}{\parbox[c]{18zw}{
{\textbf {\normalsize <xsl:apply-templates select="subject_name/name_en"/>}}
}}
\vspace{1mm}\\ \hline

% 担当教員
\multicolumn{1}{l}{\parbox[t]{8zw}{\textbf{【担当教員】}
}} <xsl:text disable-output-escaping="yes">&amp;</xsl:text> <xsl:text> </xsl:text>
\multicolumn{8}{l}{\parbox[t]{38zw}{
<xsl:apply-templates select="teachers"/>
}}
\\

% 対象学生 授業形態
\multicolumn{1}{l}{\parbox[t]{6zw}{\textbf{【対象学生】}
}} <xsl:text disable-output-escaping="yes">&amp;</xsl:text> <xsl:text> </xsl:text>
\multicolumn{3}{l}{\parbox[t]{12zw}{<xsl:value-of select="student"/>
}} <xsl:text disable-output-escaping="yes">&amp;</xsl:text> <xsl:text> </xsl:text>
\multicolumn{1}{l}{\parbox[t]{6zw}{\textbf{【授業形態】}
}} <xsl:text disable-output-escaping="yes">&amp;</xsl:text> <xsl:text> </xsl:text>
\multicolumn{4}{l}{\parbox[t]{12zw}{<xsl:apply-templates select="subject_form"/>
}}
\\

% 必修・選択の別 単位数
\multicolumn{1}{l}{\parbox[t]{8zw}{\textbf{【必修・選択の別】}
}} <xsl:text disable-output-escaping="yes">&amp;</xsl:text> <xsl:text> </xsl:text>
\multicolumn{3}{l}{\parbox[t]{12zw}{<xsl:value-of select="choice"/>
}} <xsl:text disable-output-escaping="yes">&amp;</xsl:text> <xsl:text> </xsl:text>
\multicolumn{1}{l}{\parbox[t]{6zw}{\textbf{【単\hspace{1mm}位\hspace{1mm}数】}
}} <xsl:text disable-output-escaping="yes">&amp;</xsl:text> <xsl:text> </xsl:text>
\multicolumn{4}{l}{\parbox[t]{12zw}{<xsl:value-of select="credit"/>単位
}}
\vspace{1mm}\\ \hline

% 概略
\multicolumn{2}{l}{\parbox[t]{9zw}{\textbf{【概\hspace{6mm}略】}
}} \\
\multicolumn{9}{l}{
\hspace{-2mm}\begin{minipage}{50zw}
<xsl:apply-templates select="outline"/>
\end{minipage}
}
\\

% 授業科目の到達目標
\multicolumn{2}{l}{\parbox[t]{11zw}{\textbf{【授業科目の到達目標】}
}} \\
\multicolumn{9}{l}{
\hspace{-2mm}\begin{minipage}{50zw}
<xsl:apply-templates select="object"/>
\end{minipage}
}
\\

% 履修上の注意
\multicolumn{2}{l}{\parbox[t]{8zw}{\textbf{【履修上の注意】}
}} \\
\multicolumn{9}{l}{
\hspace{-4mm}\hspace{2mm}\begin{minipage}{50zw}
\begin{tabular}{l@{ : }l}
履修の要件 <xsl:text disable-output-escaping="yes">&amp;</xsl:text> <xsl:text> </xsl:text>
\parbox[t]{42zw}{
<xsl:apply-templates select="attention/necessary"/>
} \\
その他 <xsl:text disable-output-escaping="yes">&amp;</xsl:text> <xsl:text> </xsl:text>
\parbox[t]{42zw}{
<xsl:apply-templates select="attention/others"/>
}
\end{tabular}
\end{minipage}
}
\\

% 講義内容とスケジュール
\multicolumn{3}{l}{\parbox[t]{13zw}{\textbf{【講義内容とスケジュール】}
}} \\
\multicolumn{9}{l}{
\hspace{-3mm}
<xsl:apply-templates select="subject_plan"/>
\end{minipage}
} 
\vspace{2mm}\\ \hline

% 成績評価
\multicolumn{2}{l}{\parbox[t]{6zw}{\textbf{【成績評価】}
}} \\
\multicolumn{9}{l}{
\begin{minipage}{50zw}
<xsl:apply-templates select="granding"/>
\end{minipage}
}
\\

% 関連授業科目
\multicolumn{2}{l}{\parbox[t]{8zw}{\textbf{【関連授業科目】}
}} \\
\multicolumn{9}{l}{\parbox[t]{50zw}{ <xsl:apply-templates select="relation"/>
}}
\\

% 教材
\multicolumn{2}{l}{\parbox[t]{8zw}{\textbf{【教\hspace{6mm}材】}
}} \\
\multicolumn{9}{l}{
\hspace{-1mm}\begin{minipage}{50zw}
\begin{tabular}{l@{ : }l}
教科書 <xsl:text disable-output-escaping="yes">&amp;</xsl:text> <xsl:text> </xsl:text>
\parbox[t]{44zw}{
<xsl:apply-templates select="text/text_books"/>
} \\
参考書 <xsl:text disable-output-escaping="yes">&amp;</xsl:text> <xsl:text> </xsl:text>
\parbox[t]{44zw}{
<xsl:apply-templates select="text/ref_books"/>
}
\end{tabular}
\end{minipage}
} 
\\

% 備考
\multicolumn{2}{l}{\parbox[t]{8zw}{\textbf{【備\hspace{6mm}考】}
}} \\
\multicolumn{9}{l}{
\vspace{-4mm}\begin{minipage}{50zw}
<xsl:apply-templates select="remark"/>
\end{minipage}
}

\end{tabular}
}
\end{small}
\end{center}
% \newpage

\end{document}

  </xsl:template>

   <xsl:template match="subject_name/name_en">
      <xsl:if test="not(.='')">
        <xsl:text>（</xsl:text><xsl:value-of select="."/><xsl:text>）</xsl:text>
      </xsl:if>
  </xsl:template>

   <xsl:template match="teachers">
    <xsl:for-each select="teacher">
      <xsl:apply-templates/>
	<xsl:choose>
	 <xsl:when test="./@em_form='part'">(非常勤)
	 </xsl:when>
	 <xsl:when test="./@em_form='full'">
	 </xsl:when>
	</xsl:choose>
      <xsl:if test="not(.='') and not(position()=last())">
        <xsl:text>\hspace{4mm}自室番号(</xsl:text><xsl:value-of select="/syllabus/contact/room_num"/><xsl:text>),電子メール(</xsl:text><xsl:value-of select="/syllabus/contact/e-mail"/><xsl:text>)\vspace{1mm}\\</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
 
  <xsl:template match="teacher">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="subject_form">
    <xsl:choose>
	  <xsl:when test=".='講義実技'">
	    <xsl:text>\scriptsize{</xsl:text><xsl:value-of select="."/><xsl:text>}</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="."/>
	  </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="outline">
    <xsl:for-each select="p">
      <xsl:apply-templates/>
      <xsl:if test="not(position()=last())">
        <xsl:text> \\
</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="object">
    <xsl:for-each select="p">
      <xsl:apply-templates/>
      <xsl:if test="not(position()=last())">
        <xsl:text> \\
</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="necessary">
    <xsl:for-each select="p">
      <xsl:apply-templates/>
      <xsl:if test="not(position()=last())">
        <xsl:text> \\
</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="others">
    <xsl:for-each select="p">
      <xsl:apply-templates/>
      <xsl:if test="not(position()=last())">
        <xsl:text> \\
</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="subject_plan">
    <xsl:choose>
      <xsl:when test="./@form='list'">
\hspace{-3mm}\begin{minipage}{50zw}
\begin{enumerate}
        <xsl:for-each select="li">
\item <xsl:for-each select="p">
            <xsl:apply-templates/>
            <xsl:if test="not(position()=last())">
              <xsl:text> \\
</xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
\end{enumerate}
      </xsl:when>
      <xsl:when test="./@form='free'">
\begin{minipage}{50zw}
<xsl:for-each select="p">
          <xsl:apply-templates/>
          <xsl:if test="not(position()=last())">
            <xsl:text> \\
</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="li">
\item <xsl:for-each select="p">
        <xsl:apply-templates/>
        <xsl:if test="not(position()=last())">
          <xsl:text> \\
</xsl:text>
        </xsl:if>
      </xsl:for-each>
  </xsl:template>


  <xsl:template match="granding">
    <xsl:for-each select="p">
      <xsl:apply-templates/>
      <xsl:if test="not(position()=last())">
        <xsl:text> \\
</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="relation">
    <xsl:for-each select="p">
      <xsl:apply-templates/>
      <xsl:if test="not(position()=last())">
        <xsl:text> \\
</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="text_books">
    <xsl:for-each select="book">
      <xsl:apply-templates/>
      <xsl:if test="not(position()=last())">
        <xsl:text> \\
</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="ref_books">
    <xsl:for-each select="book">
      <xsl:apply-templates/>
      <xsl:if test="not(position()=last())">
        <xsl:text> \\
</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="book">
    <xsl:value-of select="."/>
  </xsl:template>


  <xsl:template match="remark">
    <xsl:for-each select="p">
      <xsl:apply-templates/>
      <xsl:if test="not(position()=last())">
        <xsl:text> \\
</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="p">
    <xsl:value-of select="."/>
  </xsl:template>


</xsl:stylesheet>
  