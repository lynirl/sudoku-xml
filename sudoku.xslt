<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/2000/svg">
  
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  
  <!-- Variables globales pour les dimensions -->
  <xsl:variable name="cellSize" select="50"/>
  <xsl:variable name="gridSize" select="$cellSize * 9"/>
  <xsl:variable name="margin" select="80"/>
  
  <!-- Template principal -->
  <xsl:template match="/grilleSudoku">
    <svg xmlns="http://www.w3.org/2000/svg" 
         width="{$gridSize + 2 * $margin}" 
         height="{$gridSize + 2 * $margin + 100}"
         viewBox="0 0 {$gridSize + 2 * $margin} {$gridSize + 2 * $margin + 150}">
      
      <!-- Définitions de styles -->
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
        
        <!-- Filtre d'ombre portée -->
        <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
          <feGaussianBlur in="SourceAlpha" stdDeviation="2"/>
          <feOffset dx="2" dy="2" result="offsetblur"/>
          <feComponentTransfer>
            <feFuncA type="linear" slope="0.3"/>
          </feComponentTransfer>
          <feMerge>
            <feMergeNode/>
            <feMergeNode in="SourceGraphic"/>
          </feMerge>
        </filter>
      </defs>
      
      <!-- Fond général -->
      <rect x="0" y="0" width="{$gridSize + 2 * $margin}" height="{$gridSize + 2 * $margin + 150}" fill="#FEB6E8"/>
      
      <!-- Fond de la grille avec ombre -->
      <rect x="{$margin}" y="{$margin}" 
            width="{$gridSize}" height="{$gridSize}" 
            fill="white" stroke="#2c3e50" stroke-width="4" 
            filter="url(#shadow)"/>
      
      <!-- Fond des régions (alternance de couleurs) -->
      <xsl:call-template name="drawRegionBackgrounds"/>
      
      <!-- Fond des cases individuelles -->
      <xsl:apply-templates select="region/case" mode="background"/>
      
      <!-- Lignes de la grille -->
      <xsl:call-template name="drawGrid"/>
      
      <!-- Valeurs des cases -->
      <xsl:apply-templates select="region/case" mode="value"/>
      
      <!-- Statut de la grille -->
      <xsl:call-template name="displayStatus"/>
      
      <!-- Image titre par-dessus tout -->
      <image x="{($gridSize + 160) div 2 - 100}" y="10" width="200" height="60" href="assets\titre.gif"/>
      
    </svg>
  </xsl:template>
  
  <!-- Template pour dessiner les fonds des régions -->
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
  
  <!-- Template pour le fond des cases -->
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
  
  <!-- Template pour dessiner la grille -->
  <xsl:template name="drawGrid">
    <!-- Lignes horizontales -->
    <xsl:call-template name="drawHorizontalLines">
      <xsl:with-param name="current" select="0"/>
    </xsl:call-template>
    
    <!-- Lignes verticales -->
    <xsl:call-template name="drawVerticalLines">
      <xsl:with-param name="current" select="0"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- Lignes horizontales récursives -->
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
  
  <!-- Lignes verticales récursives -->
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
  
  <!-- Template pour afficher les valeurs -->
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
  
  <!-- Template pour afficher le statut -->
  <xsl:template name="displayStatus">
    <xsl:variable name="totalCases" select="count(region/case)"/>
    <xsl:variable name="isComplete" select="$totalCases = 81"/>
    
    <!-- Variables pour validation -->
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
    
    <!-- Affichage du statut -->
    <text x="{($gridSize + 2 * $margin) div 2}" y="{$gridSize + $margin + 50}">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="$hasErrors">status status-incorrect</xsl:when>
          <xsl:when test="$isComplete">status status-winning</xsl:when>
          <xsl:otherwise>status status-correct</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      
      <xsl:choose>
        <xsl:when test="$hasErrors">❌ Grille INCORRECTE (doublons détectés)</xsl:when>
        <xsl:when test="$isComplete">✓ Grille GAGNANTE !</xsl:when>
        <xsl:otherwise>⚠ Grille CORRECTE (incomplète)</xsl:otherwise>
      </xsl:choose>
    </text>
    
    <!-- Statistiques -->
    <text x="{($gridSize + 2 * $margin) div 2}" y="{$gridSize + $margin + 75}" 
          style="font-family: Arial; font-size: 14px; text-anchor: middle; fill: #7f8c8d;">
      Cases remplies: <xsl:value-of select="$totalCases"/> / 81
    </text>
  </xsl:template>
  
  <!-- Vérification des doublons dans les lignes -->
  <xsl:template name="checkDuplicatesLigne">
    <xsl:for-each select="region/case">
      <xsl:variable name="currentLigne" select="@ligne"/>
      <xsl:variable name="currentValue" select="."/>
      <xsl:if test="count(//case[@ligne = $currentLigne and . = $currentValue]) &gt; 1">
        <xsl:text>true</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <!-- Vérification des doublons dans les colonnes -->
  <xsl:template name="checkDuplicatesColonne">
    <xsl:for-each select="region/case">
      <xsl:variable name="currentColonne" select="@colonne"/>
      <xsl:variable name="currentValue" select="."/>
      <xsl:if test="count(//case[@colonne = $currentColonne and . = $currentValue]) &gt; 1">
        <xsl:text>true</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <!-- Vérification des doublons dans les régions -->
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