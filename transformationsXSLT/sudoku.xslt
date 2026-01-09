<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/2000/svg">
  
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  
<!--variables des dimensions-->
<xsl:variable name="cellSize" select="50"/>
<xsl:variable name="gridSize" select="$cellSize * 9"/>
<xsl:variable name="margin" select="100"/>

  
  <!--template principal-->
  <xsl:template match="/grilleSudoku">
    <svg xmlns="http://www.w3.org/2000/svg" 
         width="{$gridSize + 2 * $margin}" 
         height="{$gridSize + 2 * $margin + 100}"
         viewBox="0 0 {$gridSize + 2 * $margin} {$gridSize + 2 * $margin + 100}">
    
    <defs>
        <style type="text/css">
          .grid-line-thin { stroke: #999; stroke-width: 1; }
          .grid-line-thick { stroke: #333; stroke-width: 3; }
          .cell-text { font-family: Arial, sans-serif; font-size: 24px; text-anchor: middle; dominant-baseline: middle; }
          .cell-fixed { fill: #2c3e50; font-weight: bold; }
          .cell-normal { fill: #3498db; }
          .title { font-family: Arial, sans-serif; font-size: 28px; font-weight: bold; text-anchor: middle; fill: #2c3e50; }
          .status { font-family: Arial, sans-serif; font-size: 20px; text-anchor: middle; font-weight: bold; }
          .status-winning { fill: #27ae60; }
          .status-correct { fill: #f39c12; }
          .status-incorrect { fill: #e74c3c; }
          .cell-bg { fill: #ecf0f1; }
          .cell-bg-fixed { fill: #d5dbdb; }
          .region-bg-1 { fill: #e8f4f8; }
          .region-bg-2 { fill: #fef5e7; }
        </style>
      </defs>
      
      <!--background + background grille-->
      <rect x="0" y="0" width="{$gridSize + 2 * $margin}" height="{$gridSize + 2 * $margin + 100}" fill="#FEB6E8"/>

      <rect x="{$margin}" y="{$margin}" 
            width="{$gridSize}" height="{$gridSize}" 
            fill="white" stroke="#2c3e50" stroke-width="4" 
            filter="url(#shadow)"/>
      
      <!--background des regions-->
      <xsl:call-template name="drawRegionBackgrounds"/>
      
      <!--background des cases-->
      <xsl:apply-templates select="region/case" mode="background"/>
      
      <!--lignes grille-->
      <xsl:call-template name="drawGrid"/>
      
      <!--valeurs cases-->
      <xsl:apply-templates select="region/case" mode="value"/>
      
      <!--statut grille-->
      <xsl:call-template name="displayStatus"/>
      
      <!--logo ✨sudoku✨-->
      <image x="{($gridSize + 2 * $margin) div 2 - 100}" y="30" width="200" height="60" href="../assets/titre.gif"/>

      <!--divider-->
      <image x="{($gridSize + 2 * $margin) div 2 - 150}" y="{$gridSize + $margin + 95}" width="300" height="30" href="../assets/divider.gif"/>

      <!--décoration gauche-->
      <image x="40" y="{$gridSize + $margin + 70}" width="80" height="80" href="../assets/decor2.gif"/>

      <!--décoration droite-->
      <image x="{$gridSize + 2 * $margin - 120}" y="{$gridSize + $margin + 70}" width="80" height="80" href="../assets/decor1.gif"/>

      <!--cadre -->
      <image x="-40" y="-40" width="{$gridSize + 2 * $margin + 80}" height="{$gridSize + 2 * $margin + 100 + 80}" href="../assets/frame.png" preserveAspectRatio="none"/>
      
    </svg>
  </xsl:template>
  
  <!--template pour background des régions-->
  <xsl:template name="drawRegionBackgrounds">
    <xsl:variable name="regions" select="'1 3 5 7 9'"/>
    <xsl:for-each select="region">
      <xsl:variable name="regionNum" select="@numero"/>
      <xsl:variable name="rowStart" select="floor(($regionNum - 1) div 3) * 3"/>
      <xsl:variable name="colStart" select="(($regionNum - 1) mod 3) * 3"/>
      
      <xsl:variable name="bgClass">
        <xsl:choose>
          <xsl:when test="contains($regions, string($regionNum))">region-bg-1</xsl:when>
          <xsl:otherwise>region-bg-2</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <rect x="{$margin + $colStart * $cellSize}" 
            y="{$margin + $rowStart * $cellSize}"
            width="{$cellSize * 3}" 
            height="{$cellSize * 3}"
            class="{$bgClass}"/>
    </xsl:for-each>
  </xsl:template>
  
  <!--template pour background de case-->
  <xsl:template match="case" mode="background">
    <xsl:variable name="x" select="$margin + (@colonne - 1) * $cellSize"/>
    <xsl:variable name="y" select="$margin + (@ligne - 1) * $cellSize"/>
    
    <rect x="{$x + 2}" y="{$y + 2}" 
          width="{$cellSize - 4}" height="{$cellSize - 4}">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="@fixe = 'true'">cell-bg-fixed</xsl:when>
          <xsl:otherwise>cell-bg</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </rect>
  </xsl:template>
  
  <!--template pour dessiner la grille-->
  <xsl:template name="drawGrid">
    <!--lignes horizontales-->
    <xsl:call-template name="drawHorizontalLines">
      <xsl:with-param name="current" select="0"/>
    </xsl:call-template>
    
    <!--lignes verticales-->
    <xsl:call-template name="drawVerticalLines">
      <xsl:with-param name="current" select="0"/>
    </xsl:call-template>
  </xsl:template>
  
  <!--lignes horizontales récursives-->
  <xsl:template name="drawHorizontalLines">
    <xsl:param name="current"/>
    <xsl:if test="$current &lt;= 9">
      <line x1="{$margin}" y1="{$margin + $current * $cellSize}" 
            x2="{$margin + $gridSize}" y2="{$margin + $current * $cellSize}">
        <xsl:attribute name="class">
          <xsl:choose>
            <xsl:when test="$current mod 3 = 0">grid-line-thick</xsl:when>
            <xsl:otherwise>grid-line-thin</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </line>
      <xsl:call-template name="drawHorizontalLines">
        <xsl:with-param name="current" select="$current + 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <!--lignes verticales récursives-->
  <xsl:template name="drawVerticalLines">
    <xsl:param name="current"/>
    <xsl:if test="$current &lt;= 9">
      <line x1="{$margin + $current * $cellSize}" y1="{$margin}" 
            x2="{$margin + $current * $cellSize}" y2="{$margin + $gridSize}">
        <xsl:attribute name="class">
          <xsl:choose>
            <xsl:when test="$current mod 3 = 0">grid-line-thick</xsl:when>
            <xsl:otherwise>grid-line-thin</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </line>
      <xsl:call-template name="drawVerticalLines">
        <xsl:with-param name="current" select="$current + 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <!--template pour afficher valeurs -->
  <xsl:template match="case" mode="value">
    <xsl:variable name="x" select="$margin + (@colonne - 1) * $cellSize + $cellSize div 2"/>
    <xsl:variable name="y" select="$margin + (@ligne - 1) * $cellSize + $cellSize div 2"/>
    
    <text x="{$x}" y="{$y}" class="cell-text">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="@fixe = 'true'">cell-text cell-fixed</xsl:when>
          <xsl:otherwise>cell-text cell-normal</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>
  
  <!--template pour afficher le statut -->
  <xsl:template name="displayStatus">
    <xsl:variable name="totalCases" select="count(region/case)"/>
    <xsl:variable name="isComplete" select="$totalCases = 81"/>
    
    <!--variables nécessaires pr validation-->
    <xsl:variable name="duplicatesLigne">
      <xsl:call-template name="checkDuplicatesLigne"/>
    </xsl:variable>
    
    <xsl:variable name="duplicatesColonne">
      <xsl:call-template name="checkDuplicatesColonne"/>
    </xsl:variable>
    
    <xsl:variable name="duplicatesRegion">
      <xsl:call-template name="checkDuplicatesRegion"/>
    </xsl:variable>
    
    <xsl:variable name="hasErrors" select="contains($duplicatesLigne, 'true') or contains($duplicatesColonne, 'true') or contains($duplicatesRegion, 'true')"/>
    
    <!--affichage statut de la grille-->
    <text x="{($gridSize + 2 * $margin) div 2}" y="{$gridSize + $margin + 50}">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="$hasErrors">status status-incorrect</xsl:when>
          <xsl:when test="$isComplete">status status-winning</xsl:when>
          <xsl:otherwise>status status-correct</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      
      <xsl:choose>
        <xsl:when test="$hasErrors">Grille Incorrecte (doublons détectés)</xsl:when>
        <xsl:when test="$isComplete">Grille Gagnante !</xsl:when>
        <xsl:otherwise>Grille Correcte (incomplète)</xsl:otherwise>
      </xsl:choose>
    </text>
    
    <!--statistiques-->
    <text x="{($gridSize + 2 * $margin) div 2}" y="{$gridSize + $margin + 75}" 
          style="font-family: Arial; font-size: 18px; text-anchor: middle; fill: #7f8c8d;">
      Cases remplies: <xsl:value-of select="$totalCases"/> / 81
    </text>
  </xsl:template>
  
  <!--vérification doublons dans les lignes-->
  <xsl:template name="checkDuplicatesLigne">
    <xsl:for-each select="region/case">
      <xsl:variable name="currentLigne" select="@ligne"/>
      <xsl:variable name="currentValue" select="."/>
      <xsl:if test="count(//case[@ligne = $currentLigne and . = $currentValue]) &gt; 1">
        <xsl:text>true</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <!--vérification doublons dans les colonnes -->
  <xsl:template name="checkDuplicatesColonne">
    <xsl:for-each select="region/case">
      <xsl:variable name="currentColonne" select="@colonne"/>
      <xsl:variable name="currentValue" select="."/>
      <xsl:if test="count(//case[@colonne = $currentColonne and . = $currentValue]) &gt; 1">
        <xsl:text>true</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <!--vérification doublons dans les régions-->
  <xsl:template name="checkDuplicatesRegion">
    <xsl:for-each select="region/case">
      <xsl:variable name="currentRegion" select="@region"/>
      <xsl:variable name="currentValue" select="."/>
      <xsl:if test="count(//case[@region = $currentRegion and . = $currentValue]) &gt; 1">
        <xsl:text>true</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>