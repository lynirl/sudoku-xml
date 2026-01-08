<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/2000/svg">
  
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  
  <!-- Variables globales pour les dimensions -->
  <xsl:variable name="cellSize" select="50"/>
  <xsl:variable name="gridSize" select="$cellSize * 9"/>
  <xsl:variable name="margin" select="100"/>
  <xsl:variable name="chiffre" select="8"/>
  
  <!-- Template principal -->
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
          .cell-possible { fill: #27ae60; font-weight: bold; font-size: 28px; }
          
          .title { font-family: Arial, sans-serif; font-size: 28px; font-weight: bold; text-anchor: middle; fill: #2c3e50; }
          .status { font-family: Arial, sans-serif; font-size: 20px; text-anchor: middle; font-weight: bold; }
          .status-winning { fill: #27ae60; }
          .status-correct { fill:rgb(172, 75, 0); }
          .status-incorrect { fill: #e74c3c; }
          .cell-bg { fill: #ecf0f1; }
          .cell-bg-fixed { fill: #d5dbdb; }
          .cell-bg-possible { fill: #a9dfbf; }
          .cell-bg-impossible { fill: #f5b7b1; }
          .region-bg-1 { fill: #e8f4f8; }
          .region-bg-2 { fill: #fef5e7; }
        </style>
      </defs>
      
      <!-- Background -->
      <rect x="0" y="0" width="{$gridSize + 2 * $margin}" height="{$gridSize + 2 * $margin + 100}" fill="#FEB6E8"/>
      
      <!-- Background grille -->
      <rect x="{$margin}" y="{$margin}" 
            width="{$gridSize}" height="{$gridSize}" 
            fill="white" stroke="#2c3e50" stroke-width="4" 
            filter="url(#shadow)"/>
      
      <!-- Background des régions (alternance de couleurs) -->
      <xsl:call-template name="drawRegionBackgrounds"/>
      
      <!-- Traitement de toutes les cases pour possibilités -->
      <xsl:call-template name="processAllCells">
        <xsl:with-param name="ligne" select="1"/>
        <xsl:with-param name="colonne" select="1"/>
      </xsl:call-template>
      
      <!-- Lignes de la grille -->
      <xsl:call-template name="drawGrid"/>
      
      <!-- Logo -->
      <image x="{($gridSize + 2 * $margin) div 2 - 100}" y="10" width="200" height="60" href="../assets/titre.gif"/>
      
      <!-- Titre -->
      <text x="{($gridSize + 2 * $margin) div 2}" y="80" class="title">
        Possibilités pour le chiffre <xsl:value-of select="$chiffre"/>
      </text>
      
      <!-- Statut de la grille -->
      <xsl:call-template name="displayStatus"/>
      
    </svg>
  </xsl:template>
  
  <!-- Template pour traiter toutes les cases de manière récursive -->
  <xsl:template name="processAllCells">
    <xsl:param name="ligne"/>
    <xsl:param name="colonne"/>
    
    <xsl:if test="$ligne &lt;= 9">
      <xsl:variable name="region">
        <xsl:call-template name="getRegion">
          <xsl:with-param name="ligne" select="$ligne"/>
          <xsl:with-param name="colonne" select="$colonne"/>
        </xsl:call-template>
      </xsl:variable>
      
      <xsl:call-template name="processCell">
        <xsl:with-param name="ligne" select="$ligne"/>
        <xsl:with-param name="colonne" select="$colonne"/>
        <xsl:with-param name="region" select="$region"/>
      </xsl:call-template>
      
      <xsl:choose>
        <xsl:when test="$colonne &lt; 9">
          <xsl:call-template name="processAllCells">
            <xsl:with-param name="ligne" select="$ligne"/>
            <xsl:with-param name="colonne" select="$colonne + 1"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="processAllCells">
            <xsl:with-param name="ligne" select="$ligne + 1"/>
            <xsl:with-param name="colonne" select="1"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- Calcul de la région d'une case -->
  <xsl:template name="getRegion">
    <xsl:param name="ligne"/>
    <xsl:param name="colonne"/>
    <xsl:value-of select="floor(($ligne - 1) div 3) * 3 + floor(($colonne - 1) div 3) + 1"/>
  </xsl:template>

  <!-- Traitement d'une case individuelle -->
  <xsl:template name="processCell">
    <xsl:param name="ligne"/>
    <xsl:param name="colonne"/>
    <xsl:param name="region"/>
    
    <xsl:variable name="x" select="$margin + ($colonne - 1) * $cellSize"/>
    <xsl:variable name="y" select="$margin + ($ligne - 1) * $cellSize"/>
    
    <xsl:variable name="currentCase" select="//case[@ligne = $ligne and @colonne = $colonne]"/>
    <xsl:variable name="hasValue" select="string-length($currentCase) &gt; 0"/>
    
    <xsl:variable name="canPlace">
      <xsl:if test="not($hasValue)">
        <xsl:call-template name="canPlaceNumber">
          <xsl:with-param name="ligne" select="$ligne"/>
          <xsl:with-param name="colonne" select="$colonne"/>
          <xsl:with-param name="region" select="$region"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    
    <!-- Background de la case -->
    <rect x="{$x + 2}" y="{$y + 2}" width="{$cellSize - 4}" height="{$cellSize - 4}">
  <xsl:attribute name="class">
    <xsl:choose>
      <xsl:when test="$hasValue">cell-bg-fixed</xsl:when>
      
      <xsl:when test="$canPlace = 'true'">cell-bg-possible</xsl:when>
      
      <xsl:otherwise>cell-bg-impossible</xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</rect>
    
    <!-- Valeur de la case -->
    <xsl:variable name="textX" select="$x + $cellSize div 2"/>
    <xsl:variable name="textY" select="$y + $cellSize div 2"/>
    
    <xsl:choose>
      <xsl:when test="$hasValue">
        <text x="{$textX}" y="{$textY}" class="cell-text cell-fixed">
          <xsl:value-of select="$currentCase"/>
        </text>
      </xsl:when>
      <xsl:when test="$canPlace = 'true'">
        <text x="{$textX}" y="{$textY}" class="cell-text cell-possible">
          <xsl:value-of select="$chiffre"/>
        </text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- Template pour les background des régions -->
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

  <!-- Vérification si on peut placer un chiffre -->
  <xsl:template name="canPlaceNumber">
    <xsl:param name="ligne"/>
    <xsl:param name="colonne"/>
    <xsl:param name="region"/>
    
    <xsl:variable name="inLine" select="count(//case[@ligne = $ligne and . = $chiffre]) &gt; 0"/>
    <xsl:variable name="inColumn" select="count(//case[@colonne = $colonne and . = $chiffre]) &gt; 0"/>
    <xsl:variable name="inRegion" select="count(//case[@region = $region and . = $chiffre]) &gt; 0"/>
    
    <xsl:choose>
      <xsl:when test="not($inLine) and not($inColumn) and not($inRegion)">true</xsl:when>
      <xsl:otherwise>false</xsl:otherwise>
    </xsl:choose>
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
        <xsl:when test="$hasErrors">Grille Incorrecte (doublons détectés)</xsl:when>
        <xsl:when test="$isComplete">Grille Gagnante !</xsl:when>
        <xsl:otherwise>Grille Correcte (incomplète)</xsl:otherwise>
      </xsl:choose>
    </text>
    
    <!-- Statistiques -->
    <text x="{($gridSize + 2 * $margin) div 2}" y="{$gridSize + $margin + 75}" 
          style="font-family: Arial; font-size: 18px; text-anchor: middle; fill:rgb(38, 39, 40);">
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