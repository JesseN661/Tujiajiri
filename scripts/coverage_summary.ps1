param([string]$Filter = '*features*applications*')

$total = 0
$hit = 0
$file = ''
$lf = 0

foreach ($line in Get-Content coverage\lcov.info) {
  if ($line -like 'SF:*') { $file = $line.Substring(3) }
  elseif ($line -like 'LF:*') { $lf = [int]$line.Substring(3) }
  elseif ($line -like 'LH:*') {
    $lh = [int]$line.Substring(3)
    if ($file -like $Filter) {
      $total += $lf
      $hit += $lh
      '{0,6:N1}%  {1}' -f (100 * $lh / [math]::Max($lf, 1)), $file
    }
  }
}
'TOTAL {0:N1}%' -f (100 * $hit / [math]::Max($total, 1))