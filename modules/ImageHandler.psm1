using module '.\FileSystem.psm1'


class ImageHandler
{
    [int]$ImageWidth
    [int]$ImageHeight
    [int]$CprimeWidth
    [int]$CprimeHeight
    [int]$FontOffsetWidth
    [int]$FontOffsetHeight


    ImageHandler([int]$ImageWidth, [int]$ImageHeight, [int]$CprimeWidth, [int]$CprimeHeight)
    {

        $NearWidth = 33
        $NearHeight = 75
        $FarWidth = 0.7
        $FarWidth = 0.7

        $this.ImageWidth = $ImageWidth
        $this.ImageHeight = $ImageHeight
        $this.CprimeWidth = $CprimeWidth
        $this.CprimeHeight = $CprimeHeight
        $this.FontOffsetWidth = $( (($this.ImageWidth + $this.ImageHeight ) / $NearWidth ) * $FarWidth )
        $this.FontOffsetHeight = $( (($this.ImageWidth + $this.ImageHeight ) / $NearHeight ) * $FarWidth )
    }


    [int]FontZize()
    {

        return $((($this.ImageWidth + $this.ImageHeight ) / 150 ))
    }

    [int]PointSize()
    {
        return $((($this.ImageWidth + $this.ImageHeight ) / 250 ))
    }

    [System.Collections.ArrayList]APPos($APPosition)
    {

        $Positions = New-Object System.Collections.ArrayList

        $Positions.Add($( ($this.ImageWidth / $this.CprimeWidth * $APPosition.x) - $this.FontOffsetWidth ))
        $Positions.Add($( ($this.ImageHeight / $this.CprimeHeight * $APPosition.y) - $this.FontOffsetHeight ))
        $Positions.Add($( $this.ImageWidth / $this.CprimeWidth * $APPosition.x ))
        $Positions.Add($( $this.ImageHeight / $this.CprimeHeight * $APPosition.y ))

        return $Positions
    }

}