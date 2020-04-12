<!-- ESRG uses 12 units per whole pagewidth -->
<div class="grid-whole equalize">
  <div class="grid-1 m-grid-1 s-grid-6 padded">
    <div class="padded-inner content-box">
      <if @content_c1 not nil>
        @content_c1;noquote@
      </if>
    </div>
  </div>
  <div class="grid-1 m-grid-1 s-grid-6 padded">
    <div class="padded-inner content-box">
      <if @content_c2 not nil>
        @content_c2;noquote@
      </if>
    </div>
  </div>
  <div class="grid-10 m-grid-10 s-grid-12 padded">
    <div class="padded-inner content-box">
      <if @content_c3 not nill>
        @content_c3;noquote@
      </if>
    </div>
  </div>
</div>
