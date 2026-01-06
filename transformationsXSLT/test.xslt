<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/2000/svg">
  
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  
  <!-- Variables globales -->
  <xsl:variable name="cellSize" select="50"/>
  <xsl:variable name="gridSize" select="$cellSize * 9"/>
  <xsl:variable name="margin" select="80"/>
  <xsl:variable name="chiffre" select="1"/>
  
  <!-- Template principal -->
  <xsl:template match="/grilleSudoku">
    <svg xmlns="http://www.w3.org/2000/svg" 
         width="{$gridSize + 2 * $margin}" 
         height="{$gridSize + 2 * $margin + 150}"
         viewBox="0 0 {$gridSize + 2 * $margin} {$gridSize + 2 * $margin + 150}">
      
      <defs>
        <style type="text/css">
          .grid-line-thin { stroke: #999; stroke-width: 1; }
          .grid-line-thick { stroke: #333; stroke-width: 3; }
          .cell-text { font-family: Arial, sans-serif; font-size: 24px; text-anchor: middle; dominant-baseline: middle; }
          .cell-fixed { fill: #2c3e50; font-weight: bold; }
          .cell-normal { fill: #3498db; }
          .cell-possible { fill: #27ae60; font-weight: bold; font-size: 28px; }
          .title { font-family: Arial, sans-serif; font-size: 28px; font-weight: bold; text-anchor: middle; fill: #2c3e50; }
          .cell-bg { fill: #ecf0f1; }
          .cell-bg-fixed { fill: #d5dbdb; }
          .cell-bg-possible { fill: #a9dfbf; }
          .region-bg-1 { fill: #e8f4f8; }
          .region-bg-2 { fill: #fef5e7; }
        </style>
        
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
      
      <!-- Fond de la grille -->
      <rect x="{$margin}" y="{$margin}" 
            width="{$gridSize}" height="{$gridSize}" 
            fill="white" stroke="#2c3e50" stroke-width="4" 
            filter="url(#shadow)"/>
      
      <!-- Fond des régions -->
      <xsl:call-template name="drawRegionBackgrounds"/>
      
      <!-- Traiter toutes les 81 cases -->
      <xsl:call-template name="processAllCells">
        <xsl:with-param name="ligne" select="1"/>
        <xsl:with-param name="colonne" select="1"/>
      </xsl:call-template>
      
      <!-- Lignes de la grille -->
      <xsl:call-template name="drawGrid"/>
      
      <!-- Titre -->
      <text x="{($gridSize + 2 * $margin) div 2}" y="40" class="title">
        Possibilités pour le chiffre <xsl:value-of select="$chiffre"/>
      </text>
      
    </svg>
  </xsl:template>
  
  <!-- Traiter toutes les 81 cases récursivement -->
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
      
      <!-- Traiter cette case -->
      <xsl:call-template name="processCell">
        <xsl:with-param name="ligne" select="$ligne"/>
        <xsl:with-param name="colonne" select="$colonne"/>
        <xsl:with-param name="region" select="$region"/>
      </xsl:call-template>
      
      <!-- Passer à la case suivante -->
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
  
  <!-- Calculer le numéro de région -->
  <xsl:template name="getRegion">
    <xsl:param name="ligne"/>
    <xsl:param name="colonne"/>
    <xsl:value-of select="floor(($ligne - 1) div 3) * 3 + floor(($colonne - 1) div 3) + 1"/>
  </xsl:template>
  
  <!-- Traiter une case spécifique -->
  <xsl:template name="processCell">
    <xsl:param name="ligne"/>
    <xsl:param name="colonne"/>
    <xsl:param name="region"/>
    
    <xsl:variable name="x" select="$margin + ($colonne - 1) * $cellSize"/>
    <xsl:variable name="y" select="$margin + ($ligne - 1) * $cellSize"/>
    
    <!-- Récupérer la case du XML si elle existe -->
    <xsl:variable name="currentCase" select="//case[@ligne = $ligne and @colonne = $colonne]"/>
    <xsl:variable name="hasValue" select="string-length($currentCase) &gt; 0"/>
    
    <!-- Vérifier si on peut placer le chiffre -->
    <xsl:variable name="canPlace">
      <xsl:if test="not($hasValue)">
        <xsl:call-template name="canPlaceNumber">
          <xsl:with-param name="ligne" select="$ligne"/>
          <xsl:with-param name="colonne" select="$colonne"/>
          <xsl:with-param name="region" select="$region"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    
    <!-- Dessiner le fond de la case -->
    <rect x="{$x + 2}" y="{$y + 2}" 
          width="{$cellSize - 4}" height="{$cellSize - 4}">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="$canPlace = 'true'">cell-bg-possible</xsl:when>
          <xsl:when test="$hasValue">cell-bg-fixed</xsl:when>
          <xsl:otherwise>cell-bg</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </rect>
    
    <!-- Dessiner le contenu de la case -->
    <xsl:variable name="textX" select="$x + $cellSize div 2"/>
    <xsl:variable name="textY" select="$y + $cellSize div 2"/>
    
    <xsl:choose>
      <xsl:when test="$hasValue">
        <!-- Afficher la valeur existante -->
        <text x="{$textX}" y="{$textY}" class="cell-text cell-fixed">
          <xsl:value-of select="$currentCase"/>
        </text>
      </xsl:when>
      <xsl:when test="$canPlace = 'true'">
        <!-- Afficher la possibilité -->
        <text x="{$textX}" y="{$textY}" class="cell-possible">
          <xsl:value-of select="$chiffre"/>
        </text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- Dessiner les fonds des régions -->
  <xsl:template name="drawRegionBackgrounds">
    <xsl:call-template name="drawRegion">
      <xsl:with-param name="regionNum" select="1"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="drawRegion">
    <xsl:param name="regionNum"/>
    <xsl:if test="$regionNum &lt;= 9">
      <xsl:variable name="rowStart" select="floor(($regionNum - 1) div 3) * 3"/>
      <xsl:variable name="colStart" select="(($regionNum - 1) mod 3) * 3"/>
      
      <xsl:variable name="bgClass">
        <xsl:choose>
          <xsl:when test="$regionNum mod 2 = 1">region-bg-1</xsl:when>
          <xsl:otherwise>region-bg-2</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <rect x="{$margin + $colStart * $cellSize}" 
            y="{$margin + $rowStart * $cellSize}"
            width="{$cellSize * 3}" 
            height="{$cellSize * 3}"
            class="{$bgClass}"/>
      
      <xsl:call-template name="drawRegion">
        <xsl:with-param name="regionNum" select="$regionNum + 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <!-- Dessiner la grille -->
  <xsl:template name="drawGrid">
    <xsl:call-template name="drawHorizontalLines">
      <xsl:with-param name="current" select="0"/>
    </xsl:call-template>
    <xsl:call-template name="drawVerticalLines">
      <xsl:with-param name="current" select="0"/>
    </xsl:call-template>
  </xsl:template>
  
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
  
  <!-- Vérifier si on peut placer le chiffre -->
  <xsl:template name="canPlaceNumber">
    <xsl:param name="ligne"/>
    <xsl:param name="colonne"/>
    <xsl:param name="region"/>
    
    <!-- Le chiffre ne doit pas être dans la ligne -->
    <xsl:variable name="inLine" select="count(//case[@ligne = $ligne and . = $chiffre]) &gt; 0"/>
    
    <!-- Le chiffre ne doit pas être dans la colonne -->
    <xsl:variable name="inColumn" select="count(//case[@colonne = $colonne and . = $chiffre]) &gt; 0"/>
    
    <!-- Le chiffre ne doit pas être dans la région -->
    <xsl:variable name="inRegion" select="count(//case[@region = $region and . = $chiffre]) &gt; 0"/>
    
    <xsl:choose>
      <xsl:when test="not($inLine) and not($inColumn) and not($inRegion)">true</xsl:when>
      <xsl:otherwise>false</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>